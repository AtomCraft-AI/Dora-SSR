using System.Text.Json;

namespace DoraEduLauncher;

public sealed record LauncherConfiguration(
    string DoraExecutable,
    string AssetPath,
    Uri WebIdeUri,
    TimeSpan StartupTimeout,
    TimeSpan PollInterval)
{
    public static string DefaultPath => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "DoraSSREDU",
        "launcher.json");

    public static LauncherConfiguration Load(string path)
    {
        if (!File.Exists(path))
        {
            throw new FileNotFoundException("没有找到启动器配置，请重新运行协议注册脚本。", path);
        }

        LauncherConfigurationFile? file;
        try
        {
            file = JsonSerializer.Deserialize<LauncherConfigurationFile>(
                File.ReadAllText(path),
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch (JsonException ex)
        {
            throw new InvalidDataException("启动器配置不是有效的 JSON。", ex);
        }

        if (file is null
            || string.IsNullOrWhiteSpace(file.DoraExecutable)
            || string.IsNullOrWhiteSpace(file.AssetPath)
            || string.IsNullOrWhiteSpace(file.WebIdeUrl))
        {
            throw new InvalidDataException("启动器配置缺少必要字段。请重新运行协议注册脚本。");
        }

        var configDirectory = Path.GetDirectoryName(Path.GetFullPath(path))
            ?? throw new InvalidDataException("无法确定启动器配置目录。");
        var executable = ResolvePath(file.DoraExecutable, configDirectory);
        var assetPath = ResolvePath(file.AssetPath, configDirectory);

        if (!File.Exists(executable))
        {
            throw new InvalidDataException($"Dora 可执行文件不存在：{executable}");
        }
        if (!Directory.Exists(assetPath))
        {
            throw new InvalidDataException($"教育版 Assets 目录不存在：{assetPath}");
        }

        if (!Uri.TryCreate(file.WebIdeUrl, UriKind.Absolute, out var webIdeUri)
            || !string.Equals(webIdeUri.Scheme, Uri.UriSchemeHttp, StringComparison.OrdinalIgnoreCase)
            || !webIdeUri.IsLoopback
            || webIdeUri.Port != 8866
            || !string.IsNullOrEmpty(webIdeUri.UserInfo)
            || !string.IsNullOrEmpty(webIdeUri.Query)
            || !string.IsNullOrEmpty(webIdeUri.Fragment))
        {
            throw new InvalidDataException("Web IDE 地址必须是端口 8866 上的 loopback HTTP 地址。");
        }

        var startupTimeoutSeconds = file.StartupTimeoutSeconds ?? 15;
        var pollIntervalMilliseconds = file.PollIntervalMilliseconds ?? 250;
        if (startupTimeoutSeconds is < 1 or > 60)
        {
            throw new InvalidDataException("startupTimeoutSeconds 必须在 1 到 60 之间。");
        }
        if (pollIntervalMilliseconds is < 50 or > 2000
            || pollIntervalMilliseconds > startupTimeoutSeconds * 1000)
        {
            throw new InvalidDataException("pollIntervalMilliseconds 必须在 50 到 2000 之间且不大于启动超时。");
        }

        return new LauncherConfiguration(
            executable,
            assetPath,
            EnsureTrailingSlash(webIdeUri),
            TimeSpan.FromSeconds(startupTimeoutSeconds),
            TimeSpan.FromMilliseconds(pollIntervalMilliseconds));
    }

    private static string ResolvePath(string path, string baseDirectory) =>
        Path.GetFullPath(Path.IsPathFullyQualified(path) ? path : Path.Combine(baseDirectory, path));

    private static Uri EnsureTrailingSlash(Uri uri)
    {
        var builder = new UriBuilder(uri);
        if (!builder.Path.EndsWith('/')) builder.Path += "/";
        return builder.Uri;
    }

    private sealed class LauncherConfigurationFile
    {
        public string? DoraExecutable { get; init; }
        public string? AssetPath { get; init; }
        public string? WebIdeUrl { get; init; }
        public int? StartupTimeoutSeconds { get; init; }
        public int? PollIntervalMilliseconds { get; init; }
    }
}
