namespace DoraEduLauncher;

public sealed record ProtocolRequest(string Action)
{
	public const string Scheme = "dorassredu";
	public const string OpenWebIdeAction = "open-webide";

	public static bool TryParse(string[] args, out ProtocolRequest? request, out string error)
	{
		request = null;
		if (args.Length != 1 || string.IsNullOrWhiteSpace(args[0]))
		{
			error = "无效的 DoraSSR EDU 启动请求。";
			return false;
		}

		if (!Uri.TryCreate(args[0], UriKind.Absolute, out var uri)
			|| !string.Equals(uri.Scheme, Scheme, StringComparison.OrdinalIgnoreCase)
			|| !string.Equals(uri.Host, OpenWebIdeAction, StringComparison.OrdinalIgnoreCase)
			|| !string.IsNullOrEmpty(uri.UserInfo)
			|| (!string.IsNullOrEmpty(uri.AbsolutePath) && uri.AbsolutePath != "/")
			|| !string.IsNullOrEmpty(uri.Query)
			|| !string.IsNullOrEmpty(uri.Fragment)
			|| !uri.IsDefaultPort)
		{
			error = "无效的 DoraSSR EDU 启动请求。";
			return false;
		}

		request = new ProtocolRequest(OpenWebIdeAction);
		error = string.Empty;
		return true;
	}
}
