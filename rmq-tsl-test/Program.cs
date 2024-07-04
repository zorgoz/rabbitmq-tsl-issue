using RabbitMQ.Client;
using System.Net.Security;
using System.Net.Sockets;
using System.Runtime.InteropServices;

string server = RuntimeInformation.IsOSPlatform(OSPlatform.Linux) ? "rabbitmq" : "localhost";
int port = 5671;
string pfxFilePath = "../certs/generic_user_certificate.pfx";

Console.WriteLine($"Using cert file: {new FileInfo(pfxFilePath).FullName}");
Console.WriteLine($"Trying: {server}:{port}");
Console.WriteLine($"TCP port listening: {IsPortListening(server, port)}");

// try RabbitMQ connection
var factory = new ConnectionFactory 
	{ 
		HostName = server,
		Port = port,
		VirtualHost = "generic",
		AuthMechanisms = [ new ExternalMechanismFactory() ],
		Ssl = new SslOption
		{
			Enabled = true,
			ServerName = server,
			AcceptablePolicyErrors = SslPolicyErrors.RemoteCertificateNameMismatch | SslPolicyErrors.RemoteCertificateChainErrors,
			CertPath = pfxFilePath,
		}
	};

using var connection = factory.CreateConnection();

Console.WriteLine($"Connection established: {connection.Endpoint}");

static bool IsPortListening(string ipAddress, int port, int timeout = 1000)
{
	try
	{
		using (var client = new TcpClient())
		{
			var result = client.BeginConnect(ipAddress, port, null, null);
			var success = result.AsyncWaitHandle.WaitOne(TimeSpan.FromMilliseconds(timeout));
			if (!success)
			{
				return false;
			}

			client.EndConnect(result);
			return true;
		}
	}
	catch (SocketException)
	{
		return false;
	}
}
