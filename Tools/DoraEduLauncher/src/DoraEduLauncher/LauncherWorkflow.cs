using System.Diagnostics;

namespace DoraEduLauncher;

public interface ILauncherPlatform
{
    void StartDora(string executable, string assetPath);
    void OpenUrl(Uri url);
}

public interface IAsyncDelay
{
    Task DelayAsync(TimeSpan duration, CancellationToken cancellationToken);
}

public sealed class SystemAsyncDelay : IAsyncDelay
{
    public Task DelayAsync(TimeSpan duration, CancellationToken cancellationToken) =>
        Task.Delay(duration, cancellationToken);
}

public sealed record LaunchResult(bool Success, string Message)
{
    public static LaunchResult Succeeded(string message) => new(true, message);
    public static LaunchResult Failed(string message) => new(false, message);
}

public sealed class LauncherWorkflow(
    LauncherConfiguration configuration,
    IDoraStatusProbe statusProbe,
    ILauncherPlatform platform,
    IAsyncDelay delay)
{
    public async Task<LaunchResult> RunAsync(CancellationToken cancellationToken)
    {
        var initial = await statusProbe.ProbeAsync(cancellationToken);
        if (initial.Kind == ProbeKind.Education)
        {
            platform.OpenUrl(configuration.WebIdeUri);
            return LaunchResult.Succeeded("DoraSSR 教育版已经运行，已打开 Web IDE。");
        }
        if (initial.Kind == ProbeKind.OtherService)
        {
            return PortConflict(initial.Detail);
        }

        platform.StartDora(configuration.DoraExecutable, configuration.AssetPath);
        var stopwatch = Stopwatch.StartNew();
        var attempts = Math.Max(1, (int)Math.Ceiling(
            configuration.StartupTimeout.TotalMilliseconds / configuration.PollInterval.TotalMilliseconds));
        for (var attempt = 0; attempt < attempts; attempt++)
        {
            var remaining = configuration.StartupTimeout - stopwatch.Elapsed;
            if (remaining <= TimeSpan.Zero) break;

            using (var delayTimeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken))
            {
                delayTimeout.CancelAfter(remaining);
                try
                {
                    await delay.DelayAsync(Min(configuration.PollInterval, remaining), delayTimeout.Token);
                }
                catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
                {
                    break;
                }
            }

            remaining = configuration.StartupTimeout - stopwatch.Elapsed;
            if (remaining <= TimeSpan.Zero) break;

            ProbeResult probe;
            using (var probeTimeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken))
            {
                probeTimeout.CancelAfter(remaining);
                try
                {
                    probe = await statusProbe.ProbeAsync(probeTimeout.Token);
                }
                catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
                {
                    break;
                }
            }

            if (probe.Kind == ProbeKind.Education)
            {
                platform.OpenUrl(configuration.WebIdeUri);
                return LaunchResult.Succeeded("DoraSSR 教育版已启动，并已打开 Web IDE。");
            }
            if (probe.Kind == ProbeKind.OtherService)
            {
                return PortConflict(probe.Detail);
            }
        }

        return LaunchResult.Failed("等待 DoraSSR 教育版启动超时。请检查 Dora 窗口和日志后重试。");
    }

    private static TimeSpan Min(TimeSpan left, TimeSpan right) => left <= right ? left : right;

    private static LaunchResult PortConflict(string detail) => LaunchResult.Failed(
        $"端口 8866 已被其他 Dora 版本或应用占用（{detail}）。请关闭占用程序后重试。");
}
