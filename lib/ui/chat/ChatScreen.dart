// import 'dart:async';
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart' as easyLocal;
// import 'package:emartconsumer/constants.dart';
// import 'package:emartconsumer/main.dart';
// import 'package:emartconsumer/model/ChatModel.dart';
// import 'package:emartconsumer/model/ChatVideoContainer.dart';
// import 'package:emartconsumer/model/ConversationModel.dart';
// import 'package:emartconsumer/model/HomeConversationModel.dart';
// import 'package:emartconsumer/model/MessageData.dart';
// import 'package:emartconsumer/model/User.dart';
// import 'package:emartconsumer/services/FirebaseHelper.dart';
// import 'package:emartconsumer/services/helper.dart';
// import 'package:emartconsumer/ui/chat/PlayerWidget.dart';
// import 'package:emartconsumer/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
// import 'package:emartconsumer/ui/fullScreenVideoViewer/FullScreenVideoViewer.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:uuid/uuid.dart';
//
// enum RecordingState { HIDDEN, VISIBLE, Recording }
//
// class ChatScreen extends StatefulWidget {
//   final HomeConversationModel homeConversationModel;
//
//   const ChatScreen({Key? key, required this.homeConversationModel}) : super(key: key);
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final ImagePicker _imagePicker = ImagePicker();
//   late HomeConversationModel homeConversationModel;
//   final TextEditingController _messageController = TextEditingController();
//   final FireStoreUtils _fireStoreUtils = FireStoreUtils();
//   RecordingState currentRecordingState = RecordingState.HIDDEN;
//   late Timer audioMessageTimer;
//   String audioMessageTime = 'Start recording'.tr();
//   FlutterSoundRecorder? _myRecorder = FlutterSoundRecorder();
//
//   late String tempPathForAudioMessages;
//
//   late Stream<ChatModel> chatStream;
//
//   @override
//   void initState() {
//     super.initState();
//     _myRecorder!.openRecorder();
//     homeConversationModel = widget.homeConversationModel;
//     setupStream();
//   }
//
//   setupStream() {
//     chatStream = _fireStoreUtils.getChatMessages(homeConversationModel).asBroadcastStream();
//     chatStream.listen((chatModel) {
//       if (mounted) {
//         homeConversationModel.members = chatModel.members;
//         setState(() {});
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: <Widget>[
//           PopupMenuButton(
//             itemBuilder: (BuildContext context) {
//               return [
//                 PopupMenuItem(
//                     child: ListTile(
//                   dense: true,
//                   onTap: () {
//                     Navigator.pop(context);
//                     _onPrivateChatSettingsClick();
//                   },
//                   contentPadding: const EdgeInsets.all(0),
//                   leading: Icon(
//                     CupertinoIcons.gear_alt,
//                     color: isDarkMode(context) ? Colors.grey.shade200 : Colors.black,
//                   ),
//                   title: Text(
//                     'Settings'.tr(),
//                     style: const TextStyle(fontSize: 18),
//                   ),
//                 ))
//               ];
//             },
//           ),
//         ],
//         centerTitle: true,
//         actionsIconTheme: IconThemeData(color: isDarkMode(context) ? Colors.grey.shade200 : Colors.white),
//         iconTheme: IconThemeData(color: isDarkMode(context) ? Colors.grey.shade200 : Colors.white),
//         backgroundColor: Color(COLOR_PRIMARY),
//         title: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               homeConversationModel.members.first.fullName(),
//               style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : Colors.white, fontWeight: FontWeight.bold),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(2.0),
//               child: buildSubTitle(homeConversationModel.members.first),
//             )
//           ],
//         ),
//       ),
//       body: Builder(builder: (BuildContext innerContext) {
//         return Padding(
//           padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
//           child: Column(
//             children: <Widget>[
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     FocusScope.of(context).unfocus();
//                     setState(() {
//                       currentRecordingState = RecordingState.HIDDEN;
//                     });
//                   },
//                   child: StreamBuilder<ChatModel>(
//                       stream: homeConversationModel.conversationModel != null ? chatStream : null,
//                       initialData: ChatModel(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return Center(
//                             child: CircularProgressIndicator.adaptive(
//                               valueColor: AlwaysStoppedAnimation(
//                                 Color(COLOR_PRIMARY),
//                               ),
//                             ),
//                           );
//                         } else {
//                           if (snapshot.hasData && (snapshot.data?.message.isEmpty ?? true)) {
//                             return Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Center(child: showEmptyState('No Messages Yet'.tr(), context)),
//                             );
//                           } else {
//                             return ListView.builder(
//                                 reverse: true,
//                                 itemCount: snapshot.data!.message.length,
//                                 itemBuilder: (BuildContext context, int index) {
//                                   return buildMessage(snapshot.data!.message[index], snapshot.data!.members);
//                                 });
//                           }
//                         }
//                       }),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Row(
//                   children: <Widget>[
//                     IconButton(
//                       onPressed: _onCameraClick,
//                       icon: Icon(
//                         Icons.camera_alt,
//                         color: Color(COLOR_PRIMARY),
//                       ),
//                     ),
//                     Expanded(
//                         child: Padding(
//                             padding: const EdgeInsets.only(left: 2.0, right: 2),
//                             child: Container(
//                               padding: const EdgeInsets.all(2),
//                               decoration: ShapeDecoration(
//                                 shape: const OutlineInputBorder(
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(360),
//                                     ),
//                                     borderSide: BorderSide(style: BorderStyle.none)),
//                                 color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade200,
//                               ),
//                               child: Row(
//                                 children: <Widget>[
//                                   InkWell(
//                                     onTap: () => _onMicClicked(),
//                                     child: Icon(
//                                       Icons.mic,
//                                       color: currentRecordingState == RecordingState.HIDDEN ? Color(COLOR_PRIMARY) : Colors.red,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: TextField(
//                                       onChanged: (s) {
//                                         setState(() {});
//                                       },
//                                       onTap: () {
//                                         setState(() {
//                                           currentRecordingState = RecordingState.HIDDEN;
//                                         });
//                                       },
//                                       textAlignVertical: TextAlignVertical.center,
//                                       controller: _messageController,
//                                       decoration: InputDecoration(
//                                         isDense: true,
//                                         contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                                         hintText: 'Start typing'.tr(),
//                                         hintStyle: TextStyle(color: Colors.grey.shade400),
//                                         focusedBorder: const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(360),
//                                             ),
//                                             borderSide: BorderSide(style: BorderStyle.none)),
//                                         enabledBorder: const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(360),
//                                             ),
//                                             borderSide: BorderSide(style: BorderStyle.none)),
//                                       ),
//                                       textCapitalization: TextCapitalization.sentences,
//                                       maxLines: 5,
//                                       minLines: 1,
//                                       keyboardType: TextInputType.multiline,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ))),
//                     IconButton(
//                         icon: Icon(
//                           Icons.send,
//                           color: _messageController.text.isEmpty ? Color(COLOR_PRIMARY).withOpacity(.5) : Color(COLOR_PRIMARY),
//                         ),
//                         onPressed: () async {
//                           if (_messageController.text.isNotEmpty) {
//                             _sendMessage(_messageController.text, Url(mime: '', url: ''), '');
//                             _messageController.clear();
//                             setState(() {});
//                           }
//                         })
//                   ],
//                 ),
//               ),
//               _buildAudioMessageRecorder(innerContext)
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildAudioMessageRecorder(BuildContext innerContext) {
//     return Visibility(
//       visible: currentRecordingState != RecordingState.HIDDEN,
//       child: SizedBox(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             Expanded(child: Center(child: Text(audioMessageTime))),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: Stack(children: <Widget>[
//                   Row(
//                     mainAxisSize: MainAxisSize.max,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       Expanded(
//                         child: Visibility(
//                           visible: currentRecordingState == RecordingState.Recording,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(COLOR_PRIMARY),
//                               padding: const EdgeInsets.only(top: 12, bottom: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(25.0),
//                                 side: const BorderSide(style: BorderStyle.none),
//                               ),
//                             ),
//                             child: Text(
//                               'Send'.tr(),
//                               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//                             ).tr(),
//                             onPressed: () => _onSendRecord(),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 15),
//                       Expanded(
//                         child: Visibility(
//                           visible: currentRecordingState == RecordingState.Recording,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.grey.shade700,
//                               padding: const EdgeInsets.only(top: 12, bottom: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(25.0),
//                                 side: const BorderSide(style: BorderStyle.none),
//                               ),
//                             ),
//                             child: Text(
//                               'Cancel'.tr(),
//                               style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
//                             ).tr(),
//                             onPressed: () => _onCancelRecording(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     width: double.infinity,
//                     child: Visibility(
//                       visible: currentRecordingState == RecordingState.VISIBLE,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           padding: const EdgeInsets.only(top: 12, bottom: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25.0),
//                             side: const BorderSide(style: BorderStyle.none),
//                           ),
//                         ),
//                         child: Text(
//                           'record'.tr(),
//                           style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
//                         ).tr(),
//                         onPressed: () => _onStartRecording(innerContext),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//             )
//           ],
//         ),
//         height: MediaQuery.of(context).size.height * .3,
//       ),
//     );
//   }
//
//   Widget buildSubTitle(User friend) {
//     String text = friend.active ? 'activeNow'.tr() : 'lastSeenOn'.tr().tr(args: [(setLastSeen(friend.lastOnlineTimestamp.seconds))]);
//     return Text(text, style: TextStyle(fontSize: 15, color: Colors.grey.shade200));
//   }
//
//   _onCameraClick() {
//     final action = CupertinoActionSheet(
//       message: Text(
//         'Send media'.tr(),
//         style: const TextStyle(fontSize: 15.0),
//       ).tr(),
//       actions: <Widget>[
//         CupertinoActionSheetAction(
//           child: const Text('Choose image from gallery').tr(),
//           isDefaultAction: false,
//           onPressed: () async {
//             Navigator.pop(context);
//             XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
//             if (image != null) {
//               Url url = await _fireStoreUtils.uploadChatImageToFireStorage(File(image.path), context);
//               _sendMessage('', url, '');
//             }
//           },
//         ),
//         CupertinoActionSheetAction(
//           child: const Text('Choose video from gallery').tr(),
//           isDefaultAction: false,
//           onPressed: () async {
//             Navigator.pop(context);
//             XFile? galleryVideo = await _imagePicker.pickVideo(source: ImageSource.gallery);
//             if (galleryVideo != null) {
//               ChatVideoContainer videoContainer = await _fireStoreUtils.uploadChatVideoToFireStorage(File(galleryVideo.path), context);
//               _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl);
//             }
//           },
//         ),
//         CupertinoActionSheetAction(
//           child: const Text('takeAPicture').tr(),
//           isDestructiveAction: false,
//           onPressed: () async {
//             Navigator.pop(context);
//             XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
//             if (image != null) {
//               Url url = await _fireStoreUtils.uploadChatImageToFireStorage(File(image.path), context);
//               _sendMessage('', url, '');
//             }
//           },
//         ),
//         CupertinoActionSheetAction(
//           child: const Text('recordVideo').tr(),
//           isDestructiveAction: false,
//           onPressed: () async {
//             Navigator.pop(context);
//             XFile? recordedVideo = await _imagePicker.pickVideo(source: ImageSource.camera);
//             if (recordedVideo != null) {
//               ChatVideoContainer videoContainer = await _fireStoreUtils.uploadChatVideoToFireStorage(File(recordedVideo.path), context);
//               _sendMessage('', videoContainer.videoUrl, videoContainer.thumbnailUrl);
//             }
//           },
//         )
//       ],
//       cancelButton: CupertinoActionSheetAction(
//         child: Text(
//           'Cancel'.tr(),
//         ).tr(),
//         onPressed: () {
//           Navigator.pop(context);
//         },
//       ),
//     );
//     showCupertinoModalPopup(context: context, builder: (context) => action);
//   }
//
//   Widget buildMessage(MessageData messageData, List<User> members) {
//     if (messageData.senderID == MyAppState.currentUser!.userID) {
//       return myMessageView(messageData);
//     } else {
//       return remoteMessageView(
//           messageData,
//           members.where((user) {
//             return user.userID == messageData.senderID;
//           }).first);
//     }
//   }
//
//   Widget myMessageView(MessageData messageData) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           Padding(padding: const EdgeInsetsDirectional.only(end: 12.0), child: _myMessageContentWidget(messageData)),
//           displayCircleImage(messageData.senderProfilePictureURL, 35, false)
//         ],
//       ),
//     );
//   }
//
//   Widget _myMessageContentWidget(MessageData messageData) {
//     var mediaUrl = '';
//     if (messageData.url.url.isNotEmpty) {
//       if (messageData.url.mime.contains('image')) {
//         mediaUrl = messageData.url.url;
//       } else if (messageData.url.mime.contains('video')) {
//         mediaUrl = messageData.videoThumbnail;
//       } else if (messageData.url.mime.contains('audio')) {
//         mediaUrl = messageData.url.url;
//       }
//     }
//     if (mediaUrl.contains('audio')) {
//       return Stack(clipBehavior: Clip.none, alignment: Directionality.of(context) == TextDirection.ltr ? Alignment.bottomRight : Alignment.bottomLeft, children: <Widget>[
//         Positioned.directional(
//           textDirection: Directionality.of(context),
//           end: -8,
//           bottom: 0,
//           child: Image.asset(
//             Directionality.of(context) == TextDirection.ltr ? 'assets/images/chat_arrow_right.png' : 'assets/images/chat_arrow_left.png',
//             color: const Color(COLOR_ACCENT),
//             height: 12,
//           ),
//         ),
//         ConstrainedBox(
//           constraints: const BoxConstraints(
//             minWidth: 50,
//             maxWidth: 200,
//           ),
//           child: Container(
//             decoration: const BoxDecoration(
//               color: Color(COLOR_ACCENT),
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.all(
//                 Radius.circular(8),
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(4.0),
//               child: Stack(clipBehavior: Clip.hardEdge, alignment: Alignment.center, children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.only(top: 6, bottom: 6, right: 4, left: 4),
//                   child: PlayerWidget(
//                     url: messageData.url.url,
//                     color: isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade200,
//                   ),
//                 ),
//               ]),
//             ),
//           ),
//         ),
//       ]);
//     } else if (mediaUrl.isNotEmpty) {
//       return ConstrainedBox(
//           constraints: const BoxConstraints(
//             minWidth: 50,
//             maxWidth: 200,
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Stack(alignment: Alignment.center, children: [
//               GestureDetector(
//                 onTap: () {
//                   if (messageData.videoThumbnail.isEmpty) {
//                     push(
//                         context,
//                         FullScreenImageViewer(
//                           imageUrl: mediaUrl,
//                         ));
//                   }
//                 },
//                 child: Hero(
//                   tag: mediaUrl,
//                   child: CachedNetworkImage(
//                     imageUrl: getImageVAlidUrl(mediaUrl),
//                     placeholder: (context, url) => Image.asset('assets/images/img_placeholder'
//                         '.png'),
//                     errorWidget: (context, url, error) => Image.asset('assets/images/error_image'
//                         '.png'),
//                   ),
//                 ),
//               ),
//               messageData.videoThumbnail.isNotEmpty
//                   ? FloatingActionButton(
//                       mini: true,
//                       heroTag: messageData.messageID,
//                       backgroundColor: const Color(COLOR_ACCENT),
//                       onPressed: () {
//                         push(
//                             context,
//                             FullScreenVideoViewer(
//                               heroTag: messageData.messageID,
//                               videoUrl: messageData.url.url,
//                             ));
//                       },
//                       child: Icon(
//                         Icons.play_arrow,
//                         color: isDarkMode(context) ? Colors.black : Colors.white,
//                       ),
//                     )
//                   : const SizedBox(
//                       width: 0,
//                       height: 0,
//                     )
//             ]),
//           ));
//     } else {
//       return Stack(clipBehavior: Clip.none, alignment: Directionality.of(context) == TextDirection.ltr ? Alignment.bottomRight : Alignment.bottomLeft, children: <Widget>[
//         Positioned.directional(
//           textDirection: Directionality.of(context),
//           end: -8,
//           bottom: 0,
//           child: Image.asset(
//             Directionality.of(context) == TextDirection.ltr ? 'assets/images/chat_arrow_right.png' : 'assets/images/chat_arrow_left.png',
//             color: const Color(COLOR_ACCENT),
//             height: 12,
//           ),
//         ),
//         ConstrainedBox(
//           constraints: const BoxConstraints(
//             minWidth: 50,
//             maxWidth: 200,
//           ),
//           child: Container(
//             decoration: const BoxDecoration(color: Color(COLOR_ACCENT), shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(8))),
//             child: Padding(
//               padding: const EdgeInsets.all(4.0),
//               child: Stack(clipBehavior: Clip.hardEdge, alignment: Alignment.center, children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.only(top: 6, bottom: 6, right: 4, left: 4),
//                   child: Text(
//                     mediaUrl.isEmpty ? messageData.content : '',
//                     textAlign: TextAlign.start,
//                     textDirection: TextDirection.ltr,
//                     style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ]),
//             ),
//           ),
//         ),
//       ]);
//     }
//   }
//
//   Widget remoteMessageView(MessageData messageData, User sender) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Stack(
//             alignment: Directionality.of(context) == TextDirection.ltr ? Alignment.bottomRight : Alignment.bottomLeft,
//             children: <Widget>[
//               displayCircleImage(sender.profilePictureURL, 35, false),
//               Positioned.directional(
//                   textDirection: Directionality.of(context),
//                   end: 1,
//                   bottom: 1,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                         color: homeConversationModel.members.firstWhere((element) => element.userID == messageData.senderID).active ? Colors.green : Colors.grey,
//                         borderRadius: BorderRadius.circular(100),
//                         border: Border.all(color: isDarkMode(context) ? const Color(0xFF303030) : Colors.white, width: 1)),
//                   ))
//             ],
//           ),
//           Padding(padding: const EdgeInsetsDirectional.only(start: 12.0), child: _remoteMessageContentWidget(messageData)),
//         ],
//       ),
//     );
//   }
//
//   Widget _remoteMessageContentWidget(MessageData messageData) {
//     var mediaUrl = '';
//     if (messageData.url.url.isNotEmpty) {
//       if (messageData.url.mime.contains('image')) {
//         mediaUrl = messageData.url.url;
//       } else if (messageData.url.mime.contains('video')) {
//         mediaUrl = messageData.videoThumbnail;
//       } else if (messageData.url.mime.contains('audio')) {
//         mediaUrl = messageData.url.url;
//       }
//     }
//     if (mediaUrl.contains('audio')) {
//       return Stack(
//         clipBehavior: Clip.none,
//         alignment: Directionality.of(context) == TextDirection.ltr ? Alignment.bottomLeft : Alignment.bottomRight,
//         children: <Widget>[
//           Positioned.directional(
//             textDirection: Directionality.of(context),
//             start: -8,
//             bottom: 0,
//             child: Image.asset(
//               Directionality.of(context) == TextDirection.ltr ? 'assets/images/chat_arrow_left.png' : 'assets/images/chat_arrow_right.png',
//               color: isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade300,
//               height: 12,
//             ),
//           ),
//           ConstrainedBox(
//             constraints: const BoxConstraints(
//               minWidth: 50,
//               maxWidth: 200,
//             ),
//             child: Container(
//               decoration: BoxDecoration(color: isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade300, shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(8))),
//               child: Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Stack(clipBehavior: Clip.hardEdge, alignment: Alignment.center, children: <Widget>[
//                   Padding(
//                     padding: const EdgeInsets.only(top: 6, bottom: 6, right: 4, left: 4),
//                     child: PlayerWidget(
//                       url: messageData.url.url,
//                       color: isDarkMode(context) ? const Color(COLOR_ACCENT) : Color(COLOR_PRIMARY),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//           ),
//         ],
//       );
//     } else if (mediaUrl.isNotEmpty) {
//       return ConstrainedBox(
//           constraints: const BoxConstraints(
//             minWidth: 50,
//             maxWidth: 200,
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Stack(alignment: Alignment.center, children: [
//               GestureDetector(
//                 onTap: () {
//                   if (messageData.videoThumbnail.isEmpty) {
//                     push(
//                         context,
//                         FullScreenImageViewer(
//                           imageUrl: mediaUrl,
//                         ));
//                   }
//                 },
//                 child: Hero(
//                   tag: mediaUrl,
//                   child: CachedNetworkImage(
//                     imageUrl: getImageVAlidUrl(mediaUrl),
//                     placeholder: (context, url) => Image.asset('assets/images/img_placeholder'
//                         '.png'),
//                     errorWidget: (context, url, error) => Image.asset('assets/images/error_image'
//                         '.png'),
//                   ),
//                 ),
//               ),
//               messageData.videoThumbnail.isNotEmpty
//                   ? FloatingActionButton(
//                       mini: true,
//                       heroTag: messageData.messageID,
//                       backgroundColor: const Color(COLOR_ACCENT),
//                       onPressed: () {
//                         push(
//                             context,
//                             FullScreenVideoViewer(
//                               heroTag: messageData.messageID,
//                               videoUrl: messageData.url.url,
//                             ));
//                       },
//                       child: Icon(
//                         Icons.play_arrow,
//                         color: isDarkMode(context) ? Colors.black : Colors.white,
//                       ),
//                     )
//                   : const SizedBox(
//                       width: 0,
//                       height: 0,
//                     )
//             ]),
//           ));
//     } else {
//       return Stack(
//         clipBehavior: Clip.none,
//         alignment: Directionality.of(context) == TextDirection.ltr ? Alignment.bottomLeft : Alignment.bottomRight,
//         children: <Widget>[
//           Positioned.directional(
//             textDirection: Directionality.of(context),
//             start: -8,
//             bottom: 0,
//             child: Image.asset(
//               Directionality.of(context) == TextDirection.ltr ? 'assets/images/chat_arrow_left.png' : 'assets/images/chat_arrow_right.png',
//               color: isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade300,
//               height: 12,
//             ),
//           ),
//           ConstrainedBox(
//             constraints: const BoxConstraints(
//               minWidth: 50,
//               maxWidth: 200,
//             ),
//             child: Container(
//               decoration: BoxDecoration(color: isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade300, shape: BoxShape.rectangle, borderRadius: const BorderRadius.all(Radius.circular(8))),
//               child: Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Stack(clipBehavior: Clip.hardEdge, alignment: Alignment.center, children: <Widget>[
//                   Padding(
//                     padding: const EdgeInsets.only(top: 6, bottom: 6, right: 4, left: 4),
//                     child: Text(
//                       mediaUrl.isEmpty ? messageData.content : '',
//                       textAlign: TextAlign.start,
//                       textDirection: TextDirection.ltr,
//                       style: TextStyle(
//                         color: isDarkMode(context) ? Colors.white : Colors.black,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//   }
//
//   Future<bool> _checkChannelNullability(ConversationModel? conversationModel) async {
//     if (conversationModel != null) {
//       return true;
//     } else {
//       String channelID;
//       User friend = homeConversationModel.members.first;
//       User user = MyAppState.currentUser!;
//       if (friend.userID.compareTo(user.userID) < 0) {
//         channelID = friend.userID + user.userID;
//       } else {
//         channelID = user.userID + friend.userID;
//       }
//
//       ConversationModel conversation = ConversationModel(creatorId: user.userID, id: channelID, lastMessageDate: Timestamp.now(), lastMessage: 'sentAMessage'.tr(args: [(user.fullName())]));
//       bool isSuccessful = await _fireStoreUtils.createConversation(conversation);
//       if (isSuccessful) {
//         homeConversationModel.conversationModel = conversation;
//         setupStream();
//         setState(() {});
//       }
//       return isSuccessful;
//     }
//   }
//
//   _sendMessage(String content, Url url, String videoThumbnail) async {
//     MessageData message = MessageData(
//         content: content,
//         created: Timestamp.now(),
//         recipientFirstName: homeConversationModel.members.first.firstName,
//         recipientID: homeConversationModel.members.first.userID,
//         recipientLastName: homeConversationModel.members.first.lastName,
//         recipientProfilePictureURL: homeConversationModel.members.first.profilePictureURL,
//         senderFirstName: MyAppState.currentUser!.firstName,
//         senderID: MyAppState.currentUser!.userID,
//         senderLastName: MyAppState.currentUser!.lastName,
//         senderProfilePictureURL: MyAppState.currentUser!.profilePictureURL,
//         url: url,
//         videoThumbnail: videoThumbnail);
//
//     if (url.mime.contains('image')) {
//       message.content = 'sentAnImage'.tr(args: [(MyAppState.currentUser!.firstName)]);
//     } else if (url.mime.contains('video')) {
//       message.content = 'sentAVideo'.tr(args: [(MyAppState.currentUser!.firstName)]);
//     } else if (url.mime.contains('audio')) {
//       message.content = 'sentAVoiceMessage'.tr(args: [(MyAppState.currentUser!.firstName)]);
//     }
//     if (await _checkChannelNullability(homeConversationModel.conversationModel)) {
//       await _fireStoreUtils.sendMessage(homeConversationModel.members, message, homeConversationModel.conversationModel!);
//       homeConversationModel.conversationModel!.lastMessageDate = Timestamp.now();
//       homeConversationModel.conversationModel!.lastMessage = message.content;
//
//       await _fireStoreUtils.updateChannel(homeConversationModel.conversationModel!);
//     } else {
//       showAlertDialog(context, 'An error occurred'.tr(), 'Failed to send message'.tr(), true);
//     }
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _myRecorder!.closeRecorder();
//     _myRecorder = null;
//     super.dispose();
//   }
//
//   _onPrivateChatSettingsClick() {
//     final action = CupertinoActionSheet(
//       message: Text(
//         'Chat settings'.tr(),
//         style: const TextStyle(fontSize: 15.0),
//       ).tr(),
//       actions: <Widget>[
//         CupertinoActionSheetAction(
//           child: const Text('Block user').tr(),
//           onPressed: () async {
//             Navigator.pop(context);
//             showProgress(context, 'Blocking user...'.tr(), false);
//             bool isSuccessful = await _fireStoreUtils.blockUser(homeConversationModel.members.first, 'block');
//             hideProgress();
//             if (isSuccessful) {
//               Navigator.pop(context);
//               _showAlertDialog(context, 'Block'.tr(), 'hasBeenBlocked'.tr(args: [(homeConversationModel.members.first.fullName())]));
//             } else {
//               _showAlertDialog(context, 'Block'.tr(), 'couldNotBlock'.tr(args: [(homeConversationModel.members.first.fullName())]));
//             }
//           },
//         ),
//         CupertinoActionSheetAction(
//           child: const Text('Report user').tr(),
//           onPressed: () async {
//             Navigator.pop(context);
//             showProgress(context, 'reportingUser'.tr(), false);
//             bool isSuccessful = await _fireStoreUtils.blockUser(homeConversationModel.members.first, 'report');
//             hideProgress();
//             if (isSuccessful) {
//               Navigator.pop(context);
//               _showAlertDialog(context, 'Report'.tr(), "blocked-reported".tr(args: [(homeConversationModel.members.first.fullName())]));
//             } else {
//               _showAlertDialog(context, 'Report'.tr(), 'Couldn\'t report or block {}'.tr(args: [(homeConversationModel.members.first.fullName())]));
//             }
//           },
//         ),
//       ],
//       cancelButton: CupertinoActionSheetAction(
//         child: Text(
//           'Cancel'.tr(),
//         ).tr(),
//         onPressed: () {
//           Navigator.pop(context);
//         },
//       ),
//     );
//     showCupertinoModalPopup(context: context, builder: (context) => action);
//   }
//
//   _showAlertDialog(BuildContext context, String title, String message) {
//     AlertDialog alert = AlertDialog(
//       title: Text(title),
//       content: Text(message),
//     );
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   _onMicClicked() async {
//     if (currentRecordingState == RecordingState.HIDDEN) {
//       FocusScope.of(context).unfocus();
//       Directory tempDir = await getTemporaryDirectory();
//       var uniqueID = const Uuid().v4();
//       tempPathForAudioMessages = '${tempDir.path}/$uniqueID';
//       currentRecordingState = RecordingState.VISIBLE;
//     } else {
//       currentRecordingState = RecordingState.HIDDEN;
//     }
//     setState(() {});
//   }
//
//   _onSendRecord() async {
//     await _myRecorder!.stopRecorder();
//     audioMessageTimer.cancel();
//     setState(() {
//       audioMessageTime = 'Start recording'.tr();
//       currentRecordingState = RecordingState.HIDDEN;
//     });
//     Url url = await _fireStoreUtils.uploadAudioFile(File(tempPathForAudioMessages), context);
//     _sendMessage('', url, '');
//   }
//
//   _onCancelRecording() async {
//     await _myRecorder!.stopRecorder();
//     audioMessageTimer.cancel();
//     setState(() {
//       audioMessageTime = 'Start Recording'.tr();
//       currentRecordingState = RecordingState.VISIBLE;
//     });
//   }
//
//   _onStartRecording(BuildContext innerContext) async {
//     var status = await Permission.microphone.request();
//     if (status == PermissionStatus.granted) {
//       await _myRecorder!.startRecorder(toFile: tempPathForAudioMessages, codec: Codec.defaultCodec);
//       audioMessageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         setState(() {
//           audioMessageTime = updateTime(audioMessageTimer);
//         });
//       });
//       setState(() {
//         currentRecordingState = RecordingState.Recording;
//       });
//     }
//   }
// }
