import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/model/gift_cards_model.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/gift_card/gift_card_history_list_screen.dart';
import 'package:emartconsumer/ui/gift_card/gift_card_purchase_screen.dart';
import 'package:emartconsumer/ui/gift_card/gift_card_redeem_screen.dart';

class GiftCardScreen extends StatefulWidget {
  const GiftCardScreen({super.key});

  @override
  State<GiftCardScreen> createState() => _GiftCardScreenState();
}

class _GiftCardScreenState extends State<GiftCardScreen> {
  List<GiftCardsModel> giftCardList = [];

  final _pageController = PageController(viewportFraction: 0.90);
  int currentPage = 0;

  bool isLoading = true;

  @override
  void initState() {
    getGiftCard();

    super.initState();
  }

  List amount = ["1000", "2000", "5000"];

  String selectedAmount = "1000";

  getGiftCard() async {
    await FireStoreUtils.getGiftCard().then((value) {
      giftCardList = value;

      if (giftCardList.isNotEmpty) {
        messageController.text = giftCardList[currentPage].message.toString();
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  final TextEditingController amountController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Customize Gift Card", style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          InkWell(
              onTap: () {
                push(context, GiftCardHistoryListScreen());
              },
              child: Icon(Icons.history)),
          SizedBox(
            width: 10,
          ),
          InkWell(
              onTap: () {
                push(context, GiftCardRedeemScreen());
              },
              child: Icon(Icons.redeem)),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        height: 200,
                        child: PageView.builder(
                          padEnds: false,
                          itemCount: giftCardList.length,
                          scrollDirection: Axis.horizontal,
                          controller: _pageController,
                          onPageChanged: (value) {
                            setState(() {
                              currentPage = value;
                              messageController.text = giftCardList[currentPage].message.toString();
                            });
                          },
                          itemBuilder: (context, index) {
                            GiftCardsModel giftCardsModel = giftCardList[index];
                            return Container(
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white, width: 5),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    giftCardsModel.image.toString(),
                                  ),
                                ),
                              ),
                            );
                          },
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text("Swap to choose card",
                          style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.grey.shade500 : Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Text("Choose amount".toUpperCase(),
                                style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade700, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text("Gift Card amount",
                                        style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.w700))),
                                Text("${selectedAmount == "Custom" ? "" : amountShow(amount: selectedAmount)}",
                                    style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            selectedAmount == "Custom"
                                ? Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedAmount = "1000";
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(14)), border: Border.all(color: Color(COLOR_PRIMARY))),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Center(child: Text("Custom")),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(currencyData!.symbol.toString()),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: TextField(
                                        controller: amountController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Amount',
                                        ),
                                      )),
                                      InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (amountController.text.isNotEmpty) {
                                                selectedAmount = amountController.text;
                                              }
                                            });
                                          },
                                          child: Text("Add", style: TextStyle(color: Color(COLOR_PRIMARY)))),
                                    ],
                                  )
                                : Container(
                                    height: 60,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          ListView.builder(
                                            itemCount: amount.length,
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectedAmount = amount[index];
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(14)),
                                                        border: Border.all(color: selectedAmount == amount[index] ? Color(COLOR_PRIMARY) : Colors.grey)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                                      child: Center(child: Text(amountShow(amount: amount[index]))),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedAmount = "Custom";
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(14)),
                                                    border: Border.all(
                                                        color:
                                                            selectedAmount != "1000" && selectedAmount != "2000" && selectedAmount != "5000" ? Color(COLOR_PRIMARY) : Colors.grey)),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  child: Center(child: Text("Custom")),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Text("Add Message (Optional)".toUpperCase(),
                                style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade700, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: TextField(
                        controller: messageController,
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          hintText: 'Enter Message',
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 10, bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: double.infinity),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(COLOR_PRIMARY),
              padding: EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: BorderSide(
                  color: Color(COLOR_PRIMARY),
                ),
              ),
            ),
            child: Text(
              'Continue'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode(context) ? Colors.black : Colors.white,
              ),
            ),
            onPressed: () {
              if (selectedAmount.isNotEmpty && selectedAmount != "Custom") {
                push(
                  context,
                  GiftCardPurchaseScreen(
                    giftCardModel: giftCardList[currentPage],
                    price: selectedAmount,
                    msg: messageController.text,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Please Add Amount"),
                  backgroundColor: Colors.red,
                ));
              }
            },
          ),
        ),
      ),
    );
  }
}
