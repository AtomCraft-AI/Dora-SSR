using System.Text.Json;
using DoraEduLauncher;

internal static class Program
{
    private static async Task<int> Main()
    {
        var tests = new (string Name, Func<Task> Run)[]
        {
            ("accepts the exact education protocol URI", TestAcceptsProtocolUri),
            ("rejects untrusted protocol input", TestRejectsProtocolInput),
            ("loads and validates local configuration", TestLoadsConfiguration),
            ("rejects non-loopback Web IDE configuration", TestRejectsRemoteConfiguration),
            ("opens an already running education server", TestAlreadyRunning),
            ("starts Dora and waits for education readiness", TestColdStart),
            ("refuses a different service on port 8866", TestPortConflict),
            ("reports a startup timeout", TestStartupTimeout),
        };

        var failed = 0;
        foreach (var test in tests)
        {
            try
            {
                await test.Run();
                Console.WriteLine($"PASS {test.Name}");
            }
            catch (Exception ex)
            {
                failed++;
                Console.Error.WriteLine($"FAIL {test.Name}: {ex.Message}");
            }
        }

        Console.WriteLine($"RESULT {tests.Length - failed} passed, {failed} failed");
        return failed == 0 ? 0 : 1;
    }

    private static Task TestAcceptsProtocolUri()
    {
        AssertTrue(ProtocolRequest.TryParse(["dorassredu://open-webide"], out var request, out var error), error);
        AssertEqual("open-webide", request?.Action);
        return Task.CompletedTask;
    }

    private static Task TestRejectsProtocolInput()
    {
        var invalid = new[]
        {
            Array.Empty<string>(),
            new[] { "https://example.com" },
            new[] { "dorassredu://open-webide?asset=C:/tmp" },
            new[] { "dorassredu://open-webide/extra" },
            new[] { "dorassredu://run" },
            new[] { "dorassredu://open-webide", "unexpected" },
        };
        foreach (var args in invalid)
        {
            AssertFalse(ProtocolRequest.TryParse(args, out _, out _), string.Join(' ', args));
        }
        return Task.CompletedTask;
    }

    private static Task TestLoadsConfiguration()
    {
        using var fixture = new ConfigurationFixture("http://127.0.0.1:8866/");
        var config = LauncherConfiguration.Load(fixture.ConfigurationPath);
        AssertEqual(Path.GetFullPath(fixture.DoraExecutable), config.DoraExecutable);
        AssertEqual(Path.GetFullPath(fixture.AssetPath), config.AssetPath);
        AssertEqual(new Uri("http://127.0.0.1:8866/"), config.WebIdeUri);
        AssertEqual(TimeSpan.FromSeconds(2), config.StartupTimeout);
        AssertEqual(TimeSpan.FromMilliseconds(100), config.PollInterval);
        return Task.CompletedTask;
    }

    private static Task TestRejectsRemoteConfiguration()
    {
        using var fixture = new ConfigurationFixture("https://example.com:8866/");
        AssertThrows<InvalidDataException>(() => LauncherConfiguration.Load(fixture.ConfigurationPath));
        return Task.CompletedTask;
    }

    private static async Task TestAlreadyRunning()
    {
        var probe = new FakeProbe(ProbeResult.Education("1.9.2.12"));
        var platform = new FakePlatform();
        var workflow = new LauncherWorkflow(TestConfiguration(), probe, platform, new ImmediateDelay());

        var result = await workflow.RunAsync(CancellationToken.None);

        AssertTrue(result.Success, result.Message);
        AssertEqual(0, platform.StartCount);
        AssertEqual(1, platform.OpenCount);
    }

    private static async Task TestColdStart()
    {
        var probe = new FakeProbe(
            ProbeResult.Unavailable(),
            ProbeResult.Unavailable(),
            ProbeResult.Education("1.9.2.12"));
        var platform = new FakePlatform();
        var workflow = new LauncherWorkflow(TestConfiguration(), probe, platform, new ImmediateDelay());

        var result = await workflow.RunAsync(CancellationToken.None);

        AssertTrue(result.Success, result.Message);
        AssertEqual(1, platform.StartCount);
        AssertEqual("C:\\DoraEdu\\Dora.exe", platform.StartedExecutable);
        AssertEqual("C:\\DoraEdu\\Assets", platform.StartedAssetPath);
        AssertEqual(1, platform.OpenCount);
    }

    private static async Task TestPortConflict()
    {
        var platform = new FakePlatform();
        var workflow = new LauncherWorkflow(
            TestConfiguration(),
            new FakeProbe(ProbeResult.OtherService("not education")),
            platform,
            new ImmediateDelay());

        var result = await workflow.RunAsync(CancellationToken.None);

        AssertFalse(result.Success, result.Message);
        AssertContains("8866", result.Message);
        AssertEqual(0, platform.StartCount);
        AssertEqual(0, platform.OpenCount);
    }

    private static async Task TestStartupTimeout()
    {
        var platform = new FakePlatform();
        var workflow = new LauncherWorkflow(
            TestConfiguration(),
            new FakeProbe(ProbeResult.Unavailable()),
            platform,
            new ImmediateDelay());

        var result = await workflow.RunAsync(CancellationToken.None);

        AssertFalse(result.Success, result.Message);
        AssertContains("超时", result.Message);
        AssertEqual(1, platform.StartCount);
        AssertEqual(0, platform.OpenCount);
    }

    private static LauncherConfiguration TestConfiguration() => new(
        "C:\\DoraEdu\\Dora.exe",
        "C:\\DoraEdu\\Assets",
        new Uri("http://127.0.0.1:8866/"),
        TimeSpan.FromMilliseconds(300),
        TimeSpan.FromMilliseconds(100));

    private static void AssertTrue(bool condition, string? message = null)
    {
        if (!condition) throw new InvalidOperationException(message ?? "expected true");
    }

    private static void AssertFalse(bool condition, string? message = null) => AssertTrue(!condition, message ?? "expected false");

    private static void AssertEqual<T>(T expected, T actual)
    {
        if (!EqualityComparer<T>.Default.Equals(expected, actual))
        {
            throw new InvalidOperationException($"expected '{expected}', got '{actual}'");
        }
    }

    private static void AssertContains(string expected, string actual)
    {
        if (!actual.Contains(expected, StringComparison.Ordinal))
        {
            throw new InvalidOperationException($"expected '{actual}' to contain '{expected}'");
        }
    }

    private static void AssertThrows<TException>(Action action) where TException : Exception
    {
        try
        {
            action();
        }
        catch (TException)
        {
            return;
        }
        throw new InvalidOperationException($"expected {typeof(TException).Name}");
    }

    private sealed class ConfigurationFixture : IDisposable
    {
        private readonly string _root = Path.Combine(Path.GetTempPath(), "DoraEduLauncherTests", Guid.NewGuid().ToString("N"));

        public ConfigurationFixture(string webIdeUrl)
        {
            Directory.CreateDirectory(_root);
            DoraExecutable = Path.Combine(_root, "Dora.exe");
            AssetPath = Path.Combine(_root, "Assets");
            File.WriteAllBytes(DoraExecutable, []);
            Directory.CreateDirectory(AssetPath);
            ConfigurationPath = Path.Combine(_root, "launcher.json");
            File.WriteAllText(ConfigurationPath, JsonSerializer.Serialize(new
            {
                doraExecutable = DoraExecutable,
                assetPath = AssetPath,
                webIdeUrl,
                startupTimeoutSeconds = 2,
                pollIntervalMilliseconds = 100,
            }));
        }

        public string DoraExecutable { get; }
        public string AssetPath { get; }
        public string ConfigurationPath { get; }

        public void Dispose() => Directory.Delete(_root, true);
    }

    private sealed class FakeProbe(params ProbeResult[] results) : IDoraStatusProbe
    {
        private readonly Queue<ProbeResult> _results = new(results);
        private ProbeResult _last = results.Length > 0 ? results[^1] : ProbeResult.Unavailable();

        public Task<ProbeResult> ProbeAsync(CancellationToken cancellationToken)
        {
            if (_results.Count > 0) _last = _results.Dequeue();
            return Task.FromResult(_last);
        }
    }

    private sealed class FakePlatform : ILauncherPlatform
    {
        public int StartCount { get; private set; }
        public int OpenCount { get; private set; }
        public string? StartedExecutable { get; private set; }
        public string? StartedAssetPath { get; private set; }

        public void StartDora(string executable, string assetPath)
        {
            StartCount++;
            StartedExecutable = executable;
            StartedAssetPath = assetPath;
        }

        public void OpenUrl(Uri url) => OpenCount++;
    }

    private sealed class ImmediateDelay : IAsyncDelay
    {
        public Task DelayAsync(TimeSpan duration, CancellationToken cancellationToken) => Task.CompletedTask;
    }
}
