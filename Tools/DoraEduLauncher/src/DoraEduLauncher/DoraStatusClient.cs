using System.Text.Json;

namespace DoraEduLauncher;

public enum ProbeKind
{
    Unavailable,
    Education,
    OtherService,
}

public sealed record ProbeResult(ProbeKind Kind, string Detail)
{
    public static ProbeResult Unavailable() => new(ProbeKind.Unavailable, "端口 8866 尚未监听。");
    public static ProbeResult Education(string version) => new(ProbeKind.Education, version);
    public static ProbeResult OtherService(string detail) => new(ProbeKind.OtherService, detail);
}

public interface IDoraStatusProbe
{
    Task<ProbeResult> ProbeAsync(CancellationToken cancellationToken);
}

public sealed class DoraStatusClient(HttpClient httpClient, Uri webIdeUri) : IDoraStatusProbe
{
    private readonly Uri _statusUri = new(webIdeUri, "launcher/status");

    public async Task<ProbeResult> ProbeAsync(CancellationToken cancellationToken)
    {
        try
        {
            using var response = await httpClient.GetAsync(_statusUri, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return ProbeResult.OtherService($"HTTP {(int)response.StatusCode}");
            }

            await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
            var status = await JsonSerializer.DeserializeAsync<LauncherStatus>(
                stream,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true },
                cancellationToken);

            return status is { Success: true, Edition: "education" }
                ? ProbeResult.Education(status.Version ?? "unknown")
                : ProbeResult.OtherService("响应不是 DoraSSR 教育版");
        }
        catch (HttpRequestException)
        {
            return ProbeResult.Unavailable();
        }
        catch (TaskCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            return ProbeResult.Unavailable();
        }
        catch (JsonException)
        {
            return ProbeResult.OtherService("响应不是有效的教育版状态 JSON");
        }
    }

    private sealed class LauncherStatus
    {
        public bool Success { get; init; }
        public string? Edition { get; init; }
        public string? Version { get; init; }
    }
}
