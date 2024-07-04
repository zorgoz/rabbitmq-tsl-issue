using RabbitMQ.Client;
using System.Net.Security;
using System.Net;
using System.Net.Sockets;
using System.Security.Cryptography.X509Certificates;

string server = "rabbitmq";
int port = 5671;
string pfxFilePath = "../certs/generic_user_certificate.pfx";

Console.WriteLine($"Using cert file: {new FileInfo(pfxFilePath).FullName}");

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