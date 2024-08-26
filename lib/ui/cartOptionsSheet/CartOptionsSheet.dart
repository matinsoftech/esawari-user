import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/services/localDatabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartOptionsSheet extends StatefulWidget {
  final CartProduct cartProduct;

  const CartOptionsSheet({Key? key, required this.cartProduct}) : super(key: key);

  @override
  _CartOptionsSheetState createState() => _CartOptionsSheetState();
}

class _CartOptionsSheetState extends State<CartOptionsSheet> {
  late int quantity;
  late CartDatabase cartDatabase;

  @override
  void initState() {
    super.initState();
    quantity = widget.cartProduct.quantity;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .4,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(12),
            right: Radius.circular(12),
          ),
          color: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
              child: Text(
            widget.cartProduct.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )),
          const SizedBox(height: 24),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(350),
                border: Border.all(color: Colors.grey.shade300),
              ),
              height: 50,
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (quantity != 1) {
                        setState(
                          () {
                            quantity--;
                          },
                        );
                      }
                    },
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(
                        () {
                          quantity++;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const Expanded(child: SizedBox(height: 16)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                backgroundColor: Color(COLOR_PRIMARY),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
              child: Text(
                'Update Cart'.tr(),
                style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onPressed: () {
                cartDatabase.updateProduct(
                  CartProduct(
                      id: widget.cartProduct.id,
                      name: widget.cartProduct.name,
                      photo: widget.cartProduct.photo,
                      price: widget.cartProduct.price,
                      vendorID: widget.cartProduct.vendorID,
                      category_id: widget.cartProduct.category_id,
                      quantity: quantity),
                );
                Navigator.pop(context, true);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 12),
            child: CupertinoButton(
                child: Text(
                  'Remove from Cart'.tr(),
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  cartDatabase.removeProduct(widget.cartProduct.id);
                  Navigator.pop(context, true);
                }),
          )
        ],
      ),
    );
  }
}
