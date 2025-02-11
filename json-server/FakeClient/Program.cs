using System.Diagnostics;
using System.Text.Json;

class Program
{
    static void Main()
    {

        var user = new User(
            5,
            "Catalina Watkins",
            "catalins",
            "tommie28@blick.com",
            new Address(
                "1401 Missouri Ave",
                "South Milwaukee",
                "53172",
                new Geo("42.9142155", "-87.8692803")
            )
        );

        Console.WriteLine(user);

        // Serialize Dictionary to JSON
        string jsonPayload = JsonSerializer.Serialize(user, new JsonSerializerOptions { WriteIndented = false });

        // Path to PowerShell script
        string scriptPath = "client.ps1"; // Ensure this script exists in the project directory

        // Start PowerShell process
        ProcessStartInfo psi = new()
        {
            FileName = "pwsh",  // Use "powershell" for Windows PowerShell, "pwsh" for PowerShell Core
            Arguments = $"-ExecutionPolicy Bypass -File \"{scriptPath}\" -jsonPayload '{jsonPayload.Replace("'", "''")}'",
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        using Process process = new() { StartInfo = psi };
        process.Start();

        // Capture output
        string output = process.StandardOutput.ReadToEnd();
        string error = process.StandardError.ReadToEnd();

        process.WaitForExit();

        // Display output
        if (!string.IsNullOrEmpty(output))
        {
            Console.WriteLine("PowerShell Output:");
            Console.WriteLine(output);
        }

        if (!string.IsNullOrEmpty(error))
        {
            Console.WriteLine("PowerShell Error:");
            Console.WriteLine(error);
        }
    }
}
