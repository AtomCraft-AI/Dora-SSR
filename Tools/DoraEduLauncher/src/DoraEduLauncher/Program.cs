using System.Windows.Forms;

namespace DoraEduLauncher;

internal static class Program
{
	private const string MutexName = "Local\\DoraSSREDU.ProtocolLauncher";

	[STAThread]
	private static async Task<int> Main(string[] args)
	{
		ApplicationConfiguration.Initialize();
		if (!ProtocolRequest.TryParse(args, out _, out var protocolError))
		{
			ShowError(protocolError);
			return 2;
		}

		try
		{
			using var mutex = new Mutex(true, MutexName, out var ownsMutex);
			if (!ownsMutex) return 0;

			var configuration = LauncherConfiguration.Load(LauncherConfiguration.DefaultPath);
			using var httpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(1) };
			var workflow = new LauncherWorkflow(
				configuration,
				new DoraStatusClient(httpClient, configuration.WebIdeUri),
				new WindowsLauncherPlatform(),
				new SystemAsyncDelay());
			var result = await workflow.RunAsync(CancellationToken.None);
			if (!result.Success)
			{
				ShowError(result.Message);
				return 1;
			}
			return 0;
		}
		catch (Exception ex)
		{
			ShowError($"无法打开 DoraSSR 教育版。\n\n{ex.Message}");
			return 1;
		}
	}

	private static void ShowError(string message) => MessageBox.Show(
		message,
		"DoraSSR 教育版",
		MessageBoxButtons.OK,
		MessageBoxIcon.Error);
}
