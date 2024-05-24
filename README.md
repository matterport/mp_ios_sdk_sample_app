# Mobile SDK sample

This is an example application on how to create a connection to trigger certain actions inside Matterport app through a third party application.

In this specific example app you can connect to another device using BLE and send commands back and forth between the SDK enabled Matterport App and the device. Feel free to customize for your needs.

As for this moment the actions it supports are:
 - Create an Untitled job
 - Trigger a Scan
 - Complete/Close job

# Compiling

To compile simply clone this repository and open the project in Xcode. It is a minimalist version on what could be achieved through code and you can make any modifications to it to adjust to your necessities.

# Usage

Binding this sample app with the Materport App using Custom URL Scheme.

Matterport App and the Robot Companion App communicates via custom url scheme using the split view model available on iPad.

For more information, please check out [Custom URL Scheme](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app)


## Communication from the Robot companion app to the Matterport APP

The Robot Companion App communicates requests to the Matterport App via custom url scheme. The current url scheme Matterport App uses is ​​com.matterport.MatterScan://MatterScan

Below are ways Robot Companion App communicates with the Matterport app with the following enum.

```
enum Action: Int {
  case connect
  case startScan
  case createJob
  case completeJob
}
```
|URL|Description|
|-|-|
|`​​com.matterport.MatterScan://MatterScan?action=connect&identifier=<url_scheme_of_client>`|Lets the Matterport app know that a new companion has been bound. Both apps should be in the foreground in split view mode..|
|`​​com.matterport.MatterScan://MatterScan?action=createJob&identifier=<url_scheme_of_client>`|Message for requesting a Job Creation. Both apps should be in the foreground in split view mode and the jobs view should be shown..|
​​|`com.matterport.MatterScan://MatterScan?action=startScan&identifier=<url_scheme_of_client>`|Message for requesting to start a Scan. Both apps should be in the foreground in split view mode and a job should be opened.|
|`​​com.matterport.MatterScan://MatterScan?action=completeJobn&identifier=<url_scheme_of_client>`|Message for requesting job completion. (Closes current job and navigates back to the Job gallery screen). Both apps should be in the foreground in split view mode and a job should be opened.|



## Communication From the Matterport app to the Robot companion app

When a request is received from the Robot Companion App, the Matterport App will parse the identifier from the url and sends back status update to the companion app as follows:

We use the enum below to send statuses to Robot Companion App:

```
enum Status: Int {
  case connected
  case cameraReady
  case jobCreated
  case scanSuccess
  case scanFailure
  case jobCompleted
}
```

|URL|Description|
|-|-|
|`<url_scheme_of_client>?status=connected`|Notifies that the Matterport app has been connected to the Robot Companion App|
|`<url_scheme_of_client>?status=jobCreated&jobId=<uuid>`|Notifies that the Matterport app has created and opened a job with the uuid.|
|`<url_scheme_of_client>?status=cameraReady`|Notifies that the Matterport app is ready to scan. This message is fired after a job has been opened and the app is ready to perform a scan.|
|`<url_scheme_of_client>?status=scanSuccess`|Notifies that the Matterport app has performed a scan successfully.|
|`<url_scheme_of_client>?status=scanFailure`|Notifies that the Matterport app failed to perform a scan.|
|`​​com.matterport.MatterScan://MatterScan?action=jobCompleted`|Notifies that the Matterport app has completed (closed) a job successfully.|




