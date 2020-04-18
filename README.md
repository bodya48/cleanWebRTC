# cleanWebRTC

Demo iOS app with simple call funcionality to check WebRTC.framework against https://appr.tc connection server.

Features:
* support 1:1 conection via ios - web call (as soon as you have valid room ID from server)
* support 1:1 connection via ios - ios call (the same aplied here: as soon as you have valid room ID from server)

Architecture:
* I use WebRTC framework compiled from the source code in Dec'19 - Jan'20
* WebRTC.framework was compiled with the following codecs enabled:
** H264 (High)
** H264 (Baseline)
** H264 (Baseline, 42e01f profile, kRTCLevel31ConstrainedBaseline. Manually added in the source code)
** VP8 
** VP9 (enabled in settings before compilation)
* AppClient connection classes from AppRTCMobile demo app by Google (Objective C language)
* cleanWebRTC app classes in Swift language
