import 'dart:io';
import 'package:get/get.dart';
import 'package:inventory/views/shared.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../repo/app_repo.dart';

class AutoUpdater {
  // URL to download the update from
  final String updateUrl;
  
  // Constructor
  AutoUpdater({required this.updateUrl});
  
  Future<void> performUpdate() async {
    try {
      // Get the executable directory path
      final String executableDir = (await getApplicationDocumentsDirectory()).path;
      
      // Download and save the zip file
      final zipFilePath = path.join(executableDir, 'billyautoplussetup.exe');
      await _downloadFile(updateUrl, zipFilePath);
      print('Downloaded update to: $zipFilePath');
      Ui.showInfo('Downloaded update to: $zipFilePath, preparing to install...');
      
      // Start an external process that will survive this app closing
      // Using a detached process
      Process? watcherProcess;
      if (Platform.isWindows) {
        // On Windows, create a detached process
        watcherProcess = await Process.start(
          'powershell.exe',
          ['-WindowStyle', 'Hidden', '-Command', """
            start '$zipFilePath';
          """],
          mode: ProcessStartMode.detached,
        );
      } 
      // else if (Platform.isLinux || Platform.isMacOS) {
      //   // For Linux/macOS
      //   final scriptPath = path.join(executableDir, 'update_script.sh');
      //   final script = '''
      //     #!/bin/bash
      //     sleep 2
          
      //     # Delete all files except the zip
      //     find "$executableDir" -type f -not -name "update.zip" -delete
      //     find "$executableDir" -type d -not -path "$executableDir" -delete
          
      //     # Extract the zip
      //     unzip "$zipFilePath" -d "$executableDir"
          
      //     # Remove the zip file
      //     rm "$zipFilePath"
          
      //     # Start the new instance
      //     "$executableDir/inventory.exe" &
      //   ''';
        
      //   // Write the script
      //   await File(scriptPath).writeAsString(script);
      //   await Process.run('chmod', ['+x', scriptPath]);
        
      //   // Run the script in a detached process
      //   watcherProcess = await Process.start(
      //     scriptPath, 
      //     [],
      //     mode: ProcessStartMode.detached,
      //   );
      // }
      await Future.delayed(Duration(seconds: 8));
      print('Started updater process with PID: ${watcherProcess?.pid}');
      
      // Exit the current application
      exit(0);
    } catch (e) {
      print('Update process failed: $e');
      rethrow;
    }
  }
  
  // Helper method to download a file
  Future<void> _downloadFile(String url, String savePath) async {
    await Get.find<AppRepo>().apiService.download(url, savePath);
  }
}