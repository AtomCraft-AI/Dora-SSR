using System.Diagnostics;

namespace DoraEduLauncher;

public sealed class WindowsLauncherPlatform : ILauncherPlatform
{
	public void StartDora(string executable, string assetPath)
	{
		var startInfo = new ProcessStartInfo
		{
			FileName = executable,
			UseShellExecute = false,
			CreateNoWindow = true,
			WorkingDirectory = Path.GetDirectoryName(executable)
				?? throw new InvalidOperationException("无法确定 Dora 工作目录。"),
		};
		startInfo.ArgumentList.Add("--asset");
		startInfo.ArgumentList.Add(assetPath);
		_ = Process.Start(startInfo)
			?? throw new InvalidOperationException("操作系统未能创建 Dora 进程。");
	}

	public void OpenUrl(Uri url)
	{
		_ = Process.Start(new ProcessStartInfo
		{
			FileName = url.AbsoluteUri,
			UseShellExecute = true,
		}) ?? throw new InvalidOperationException("操作系统未能打开 Web IDE 地址。");
	}
}
