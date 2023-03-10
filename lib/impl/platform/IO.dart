import 'dart:core';
import 'dart:typed_data';

import 'dart:io';

/// IO operations used by the API, must be implemented by the target platform to use the API.
abstract class IO {
  /// Save the data to the local device
  /// @param key     Key value identifying the data
  /// @param data    Data to save
  /// @throws IOException If I/O error occurs
  void localSave(String key, Uint8List data);

  /// Retrieves data saved locally to the device
  /// @param key    Key value identifying the data
  /// @return Stream to read the data
  /// @throws IOException If I/O error occurs
  Stream<int> localRetrieve(String key);

  /// Downloads a file from a URL and stores it locally on the device.  When downloaded, the file
  /// can be later retrieved using {@link #findDownloadedFile(String)}.
  /// @param srcUrl    URL to retrieve the file from
  /// @param dest      Where to store the downloaded file
  /// @return Task holding the downloaded file, if successful
  Future<File> downloadFileAsync(String srcUrl, String dest);

  /// Finds a downloaded file matching the name.  Before using the returned object, check if the
  /// file exists by calling {@link File#exists()}
  /// @param filename    File to search for
  /// @return File object representing the desired file
  File findDownloadedFile(String filename);

  /// Outputs a warn level message to the logger
  /// @param tag        Value identifying the message
  /// @param message    Message to log
  void logWarn(String tag, String message);
  /**
     * Outputs a warn level message to the logger with an exception or error associated with the message
     * @param tag        Value identifying the message
     * @param message    Message to log
     * @param tr         Additional information to provide to the logger
     */
//    void logWarn(String tag, String message, Throwable tr);
}
