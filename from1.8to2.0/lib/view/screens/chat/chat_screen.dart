import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/chat_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/data/model/response/conversation_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/user_type.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:sixam_mart/view/screens/chat/widget/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final NotificationBody notificationBody;
  final User user;
  final int conversationID;
  final int index;
  final bool fromNotification;
  const ChatScreen({@required this.notificationBody, @required this.user, this.conversationID, this.index, this.fromNotification = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();
  bool _isLoggedIn;
  StreamSubscription _stream;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    if(_isLoggedIn) {
      Get.find<ChatController>().getMessages(1, widget.notificationBody, widget.user, widget.conversationID, firstLoad: true);

      if(Get.find<UserController>().userInfoModel == null || Get.find<UserController>().userInfoModel.userInfo == null) {
        Get.find<UserController>().getUserInfo();
      }
    }

  }

  @override
  void dispose() {
    super.dispose();
    _stream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {
      String _baseUrl = '';
      if(widget.notificationBody.adminId != null) {
        _baseUrl = Get.find<SplashController>().configModel.baseUrls.businessLogoUrl;
      }else if(widget.notificationBody.deliverymanId != null) {
        _baseUrl = Get.find<SplashController>().configModel.baseUrls.deliveryManImageUrl;
      }else {
        _baseUrl = Get.find<SplashController>().configModel.baseUrls.storeImageUrl;
      }

      return WillPopScope(
        onWillPop: () async{
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
            return true;
          } else {
            Get.back();
            return true;
          }
        },
        child: Scaffold(
          endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : AppBar(
            leading: IconButton(
              onPressed: () {
                if(widget.fromNotification) {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }else {
                  Get.back();
                }
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
            title: Text(chatController.messageModel != null ? '${chatController.messageModel.conversation.receiver.fName}'
                ' ${chatController.messageModel.conversation.receiver.lName}' : 'receiver_name'.tr),
            backgroundColor: Theme.of(context).primaryColor,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 40, height: 40, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 2,color: Theme.of(context).cardColor),
                    color: Theme.of(context).cardColor,
                  ),
                  child: ClipOval(child: CustomImage(
                    image:'$_baseUrl'
                        '/${chatController.messageModel != null ? chatController.messageModel.conversation.receiver.image : ''}',
                    fit: BoxFit.cover, height: 40, width: 40,
                  )),
                ),
              )
            ],
          ),

          body: _isLoggedIn ? SafeArea(
            child: Center(
              child: Container(
                width: ResponsiveHelper.isDesktop(context) ? Dimensions.WEB_MAX_WIDTH : MediaQuery.of(context).size.width,
                child: Column(children: [

                  GetBuilder<ChatController>(builder: (chatController) {
                    return Expanded(child: chatController.messageModel != null ? chatController.messageModel.messages.length > 0 ? SingleChildScrollView(
                      controller: _scrollController,
                      reverse: true,
                      child: PaginatedListView(
                        scrollController: _scrollController,
                        reverse: true,
                        totalSize: chatController.messageModel != null ? chatController.messageModel.totalSize : null,
                        offset: chatController.messageModel != null ? chatController.messageModel.offset : null,
                        onPaginate: (int offset) async => await chatController.getMessages(
                          offset, widget.notificationBody, widget.user, widget.conversationID,
                        ),
                        itemView: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: chatController.messageModel.messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(
                              message: chatController.messageModel.messages[index],
                              user: chatController.messageModel.conversation.receiver,
                              userType: widget.notificationBody.adminId != null ? UserType.admin
                                  : widget.notificationBody.deliverymanId != null ? UserType.delivery_man : UserType.vendor,
                            );
                          },
                        ),
                      ),
                    ) : Center(child: Text('no_message_found'.tr)) : Center(child: CircularProgressIndicator()));
                  }),

                  (chatController.messageModel != null && (chatController.messageModel.status || chatController.messageModel.messages.length <= 0)) ? Container(
                    color: Theme.of(context).cardColor,
                    child: Column(children: [

                      GetBuilder<ChatController>(builder: (chatController) {

                        return chatController.chatImage.length > 0 ? Container(height: 100,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: chatController.chatImage.length,
                              itemBuilder: (BuildContext context, index){
                                return  chatController.chatImage.length > 0 ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(children: [

                                    Container(width: 100, height: 100,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(Dimensions.PADDING_SIZE_DEFAULT)),
                                        child: Image.memory(
                                          chatController.chatRawImage[index], width: 100, height: 100, fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Positioned(top:0, right:0,
                                      child: InkWell(
                                        onTap : () => chatController.removeImage(index, _inputMessageController.text.trim()),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(Dimensions.PADDING_SIZE_DEFAULT))
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(Icons.clear, color: Colors.red, size: 15),
                                          ),
                                        ),
                                      ),
                                    )],
                                  ),
                                ) : SizedBox();
                              }),
                        ) : SizedBox();
                      }),

                      Row(children: [

                        InkWell(
                          onTap: () async {
                            Get.find<ChatController>().pickImage(false);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                            child: Image.asset(Images.image, width: 25, height: 25, color: Theme.of(context).hintColor),
                          ),
                        ),

                        SizedBox(
                          height: 25,
                          child: VerticalDivider(width: 0, thickness: 1, color: Theme.of(context).hintColor),
                        ),
                        SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),

                        Expanded(
                          child: TextField(
                            inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.MESSAGE_INPUT_LENGTH)],
                            controller: _inputMessageController,
                            textCapitalization: TextCapitalization.sentences,
                            style: robotoRegular,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'type_here'.tr,
                              hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                            ),
                            onSubmitted: (String newText) {
                              if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                Get.find<ChatController>().toggleSendButtonActivity();
                              }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                Get.find<ChatController>().toggleSendButtonActivity();
                              }
                            },
                            onChanged: (String newText) {
                              if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                Get.find<ChatController>().toggleSendButtonActivity();
                              }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                Get.find<ChatController>().toggleSendButtonActivity();
                              }
                            },
                          ),
                        ),

                        GetBuilder<ChatController>(builder: (chatController) {
                          return chatController.isLoading ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                            child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()),
                          ) : InkWell(
                            onTap: () async {
                              if(chatController.isSendButtonActive) {
                                await chatController.sendMessage(
                                  message: _inputMessageController.text, notificationBody: widget.notificationBody,
                                  conversationID: widget.conversationID, index: widget.index,
                                );
                                _inputMessageController.clear();
                              }else {
                                showCustomSnackBar('write_something'.tr);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                              child: Image.asset(
                                Images.send, width: 25, height: 25,
                                color: chatController.isSendButtonActive ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                              ),
                            ),
                          );
                        }
                        ),

                      ]),
                    ]),
                  ) : SizedBox(),
                ],
                ),
              ),
            ),
          ) : NotLoggedInScreen(),
        ),
      );
    });
  }
}
