import 'package:sixam_mart/controller/campaign_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/basic_campaign_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampaignScreen extends StatefulWidget {
  final BasicCampaignModel campaign;
  CampaignScreen({@required this.campaign});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<CampaignController>().getBasicCampaignDetails(widget.campaign.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
      endDrawer: MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<CampaignController>(builder: (campaignController) {
        return CustomScrollView(
          slivers: [

            ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
              child: Container(
                color: Color(0xFF171A29),
                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  child: CustomImage(
                    fit: BoxFit.cover, height: 220, width: 1150,
                    image: '${Get.find<SplashController>().configModel.baseUrls.campaignImageUrl}/${widget.campaign.image}',
                  ),
                ),
              ),
            ) : SliverAppBar(
              expandedHeight: 230,
              toolbarHeight: 50,
              pinned: true,
              floating: false,
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(icon: Icon(Icons.chevron_left, color: Colors.white), onPressed: () => Get.back()),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.campaign.title,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white),
                ),
                background: CustomImage(
                  fit: BoxFit.cover,
                  image: '${Get.find<SplashController>().configModel.baseUrls.campaignImageUrl}/${widget.campaign.image}',
                ),
              ),
            ),

            SliverToBoxAdapter(child: FooterView(child: Container(
              width: Dimensions.WEB_MAX_WIDTH,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
              ),
              child: Column(children: [

                campaignController.campaign != null ? Column(
                  children: [

                    Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        child: CustomImage(
                          image: '${Get.find<SplashController>().configModel.baseUrls.campaignImageUrl}/${campaignController.campaign.image}',
                          height: 40, width: 50, fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          campaignController.campaign.title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          campaignController.campaign.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                      ])),
                    ]),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                    campaignController.campaign.startTime != null ? Row(children: [
                      Text('campaign_schedule'.tr, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                      )),
                      SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      Text(
                        '${DateConverter.stringToLocalDateOnly(campaignController.campaign.availableDateStarts)}'
                            ' - ${DateConverter.stringToLocalDateOnly(campaignController.campaign.availableDateEnds)}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                      ),
                    ]) : SizedBox(),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                    campaignController.campaign.startTime != null ? Row(children: [
                      Text('daily_time'.tr, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                      )),
                      SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      Text(
                        '${DateConverter.convertTimeToTime(campaignController.campaign.startTime)}'
                            ' - ${DateConverter.convertTimeToTime(campaignController.campaign.endTime)}',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                      ),
                    ]) : SizedBox(),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                  ],
                ) : SizedBox(),

                ItemsView(
                  isStore: true, items: null,
                  stores: campaignController.campaign != null ? campaignController.campaign.store : null,
                ),

              ]),
            ))),
          ],
        );
      }),
    );
  }
}