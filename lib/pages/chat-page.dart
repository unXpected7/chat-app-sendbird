import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:chat_app_sendbird/widgets/main-widget.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:intl/intl.dart';

class OpenChannelPage extends StatefulWidget {
  OpenChannelPage(Key? key, this.sendbirdSdk, this.user) : super(key: key);
  final SendbirdSdk? sendbirdSdk;
  final User? user;
  final Widgets widgets = Widgets();

  @override
  State<OpenChannelPage> createState() => OpenChannelPageState();
}

//
class OpenChannelPageState extends State<OpenChannelPage> {
  final channelUrl =
      "sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211";
  final itemScrollController = ItemScrollController();
  final textEditingController = TextEditingController();
  late PreviousMessageListQuery query;

  String title = '';
  bool hasPrevious = false;
  List<BaseMessage> messageList = [];
  int? participantCount;
  bool loading = true;
  bool error = false;

  OpenChannel? openChannel;

  @override
  void initState() {
    super.initState();
    widget.sendbirdSdk!
        .addChannelEventHandler('OpenChannel', MyOpenChannelHandler(this));
    widget.sendbirdSdk!
        .addConnectionEventHandler('OpenChannel', MyConnectionHandler(this));

    OpenChannel.getChannel(channelUrl).then((openChannel) {
      this.openChannel = openChannel;
      openChannel.enter().then((_) => _initialize());
    });
  }

  void _initialize() {
    try {
      OpenChannel.getChannel(channelUrl).then((openChannel) {
        query = PreviousMessageListQuery(
          channelType: ChannelType.open,
          channelUrl: channelUrl,
        );

        query.loadNext().then((messages) {
          setState(() {
            messageList
              ..clear()
              ..addAll(messages);
            title = '${openChannel.name}';
            hasPrevious = query.hasNext;
            participantCount = openChannel.participantCount;
          });
        });
      });
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  @override
  void dispose() {
    widget.sendbirdSdk!.removeChannelEventHandler('OpenChannel');
    widget.sendbirdSdk!.removeConnectionEventHandler('OpenChannel');
    textEditingController.dispose();

    OpenChannel.getChannel(channelUrl).then((channel) => channel.exit());
    super.dispose();
  }

  void _createMessage(BaseMessage message) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        messageList.add(message);
        title = '${openChannel.name}';
        participantCount = openChannel.participantCount;
      });

      Future.delayed(
        const Duration(milliseconds: 100),
        () => _scroll(messageList.length - 1),
      );
    });
  }

  void _updateMessage(BaseMessage message) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        for (int index = 0; index < messageList.length; index++) {
          if (messageList[index].messageId == message.messageId) {
            messageList[index] = message;
            break;
          }
        }

        title = '${openChannel.name}';
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _deleteMessage(int messageId) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        for (int index = 0; index < messageList.length; index++) {
          if (messageList[index].messageId == messageId) {
            messageList.removeAt(index);
            break;
          }
        }
        title = '${openChannel.name}';
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _updateParticipantCount() {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _scroll(int index) async {
    if (messageList.length <= 1) return;

    while (!itemScrollController.isAttached) {
      await Future.delayed(const Duration(milliseconds: 1));
    }

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget _chatBuilderSender(BuildContext context, BaseMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.w),
              margin: EdgeInsets.only(right: 5.w),
              constraints: BoxConstraints(maxWidth: 70.w),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                gradient: LinearGradient(colors: [
                  const Color.fromARGB(255, 255, 0, 107),
                  const Color.fromARGB(255, 255, 69, 147)
                ], begin: Alignment.topLeft, end: Alignment.bottomCenter),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(1.5.w),
                  topLeft: Radius.circular(6.w),
                  bottomRight: Radius.circular(6.w),
                  bottomLeft: Radius.circular(6.w),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                        fontSize: 5.w,
                        color: Color.fromARGB(255, 244, 240, 240)),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget _chatBuilderReceiver(BuildContext context, BaseMessage message) {
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.widgets.buildImageNetwork(
              message.sender?.profileUrl, 10.w, Icons.account_circle),
          SizedBox(
            width: 3.w,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.w),
            margin: EdgeInsets.only(right: 1.w),
            constraints: BoxConstraints(maxWidth: 60.w),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color.fromARGB(255, 26, 26, 26),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(1.5.w),
                topRight: Radius.circular(5.w),
                bottomRight: Radius.circular(5.w),
                bottomLeft: Radius.circular(5.w),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: 40.w),
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        message.sender?.userId ?? "Unknown",
                        style: TextStyle(
                            fontSize: 4.w,
                            color: Color.fromARGB(255, 165, 164, 164)),
                      ),
                    ),
                    SizedBox(
                      width: 3.w,
                    ),
                    Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 3, 238, 238),
                      ),
                    )
                  ],
                ),
                Text(
                  message.message,
                  style: TextStyle(
                      fontSize: 5.w, color: Color.fromARGB(255, 215, 213, 213)),
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 22.w),
            height: 15.w,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(child: Container()),
              Text(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                DateFormat('MMM dd, hh a')
                    .format(
                        DateTime.fromMillisecondsSinceEpoch(message.createdAt))
                    .toString(),
                style: const TextStyle(
                    fontSize: 12.0,
                    color: Color.fromARGB(255, 165, 164, 164),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _showPopUpToResend(UserMessage message) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Text('Resend: ${message.message}'),
            actions: [
              TextButton(
                onPressed: () {
                  openChannel?.resendUserMessage(
                    message,
                    onCompleted: (message, e) async {
                      if (e != null) {
                        await _showPopUpToResend(message);
                      } else {
                        _createMessage(message);
                      }
                    },
                  );
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  Widget sendField() {
    return Container(
        color: Color.fromARGB(255, 19, 19, 19),
        child: Row(children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add_outlined,
              color: Colors.white,
              size: 10.w,
              opticalSize: 1.w,
            ),
            padding: EdgeInsets.all(5),
            color: Color.fromARGB(255, 187, 176, 176),
          ),
          Expanded(
              child: Container(
            margin:
                EdgeInsets.only(right: 5.w, bottom: 2.w, top: 2.w, left: 1.w),
            padding:
                EdgeInsets.only(left: 5.w, right: 2.w, top: 0.w, bottom: 0.w),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1, color: Color.fromARGB(255, 64, 64, 64)),
                color: Color.fromARGB(255, 26, 26, 26),
                borderRadius: BorderRadius.circular(8.w)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                    maxLines: 1,
                    controller: textEditingController,
                    style: TextStyle(
                        fontSize: 5.w,
                        color: Color.fromARGB(255, 244, 240, 240)),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'type  text..',
                        hintStyle: TextStyle(
                            fontSize: 5.w,
                            color: Color.fromARGB(255, 64, 64, 64)),
                        constraints:
                            BoxConstraints(maxWidth: 237, maxHeight: 50))),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 0, 106),
                      borderRadius: BorderRadius.all(Radius.circular(23))),
                  child: IconButton(
                    onPressed: () async {
                      if (textEditingController.value.text.isEmpty) {
                        return;
                      }
                      openChannel?.sendUserMessage(
                        UserMessageParams(
                            message: textEditingController.value.text,
                            data: TimeOfDay.now().toString()),
                        onCompleted: (UserMessage message, Error? e) async {
                          if (e != null) {
                            await _showPopUpToResend(message);
                          } else {
                            _createMessage(message);
                          }
                        },
                      );

                      textEditingController.clear();
                    },
                    icon: Icon(Icons.arrow_upward),
                    padding: EdgeInsets.all(5),
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                )
              ],
            ),
          )),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 7.w),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: Color.fromARGB(255, 14, 13, 13),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 5.w, color: Color.fromARGB(255, 244, 240, 240)),
          maxLines: 1,
        ),
        actions: [
          Icon(
            Icons.menu_rounded,
            size: 10.w,
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 14, 13, 13),
        child: loading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 168, 168, 168),
                ),
              )
            : error
                ? Center(
                    child: Text(
                    "Error while loading chat",
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 176, 174, 174)),
                  ))
                : Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      messageList.isNotEmpty
                          ? _listChat()
                          : Container(
                              color: Color.fromARGB(255, 14, 13, 13),
                            ),
                      sendField(),
                      // hasPrevious ? _previousButton() : Container(),
                    ],
                  ),
      ),
    );
  }

  Widget _previousButton() {
    return Positioned(
      top: 0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color.fromARGB(255, 58, 57, 57),
            width: 1.0,
          ),
          color: Color.fromARGB(255, 172, 172, 172),
        ),
        child: IconButton(
          icon: Icon(Icons.expand_less, size: 6.w),
          color: Color.fromARGB(255, 11, 6, 6),
          onPressed: () async {
            print("previous button been pressed");
            if (query.hasNext && !query.loading) {
              final messages = await query.loadNext();
              final openChannel = await OpenChannel.getChannel(channelUrl);
              setState(() {
                messageList.insertAll(0, messages);
                title = '${openChannel.name}';
                hasPrevious = query.hasNext;
              });
              _scroll(0);
            }
          },
        ),
      ),
    );
  }

  Widget _listChat() {
    return Container(
      padding: EdgeInsets.only(bottom: 20.w),
      child: ScrollablePositionedList.builder(
        physics: const ClampingScrollPhysics(),
        initialScrollIndex: messageList.length - 1,
        itemScrollController: itemScrollController,
        itemCount: messageList.length,
        itemBuilder: (BuildContext context, int index) {
          if (index >= messageList.length) return Container();

          BaseMessage message = messageList[index];

          if (message.sender?.userId == widget.user?.userId) {
            return _chatBuilderSender(context, message);
          } else {
            return _chatBuilderReceiver(context, message);
          }
        },
      ),
    );
  }
}

class MyOpenChannelHandler extends ChannelEventHandler {
  final OpenChannelPageState _state;

  MyOpenChannelHandler(this._state);

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    _state._createMessage(message);
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    _state._updateMessage(message);
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    _state._deleteMessage(messageId);
  }

  @override
  void onUserEntered(OpenChannel channel, User user) {
    _state._updateParticipantCount();
  }

  @override
  void onUserExited(OpenChannel channel, User user) {
    _state._updateParticipantCount();
  }
}

class MyConnectionHandler extends ConnectionEventHandler {
  final OpenChannelPageState _state;

  MyConnectionHandler(this._state);

  @override
  void onConnected(String userId) {}

  @override
  void onDisconnected(String userId) {}

  @override
  void onReconnectStarted() {}

  @override
  void onReconnectSucceeded() {
    _state._initialize();
  }

  @override
  void onReconnectFailed() {}
}
