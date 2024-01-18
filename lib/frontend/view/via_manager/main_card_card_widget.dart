// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:np_financr/backend/finances_main/cards(all)/card_details.dart';
import '../../../backend/widgets/constants/constants.dart';

import '../../../backend/providers/main_function_providers/card_provider.dart';
import '../../../backend/finances_main/cards(all)/edit_card.dart';
import '../../../data/models/app_models/card_model.dart';

class CardToolListWidget extends ConsumerStatefulWidget {
  const CardToolListWidget({required this.getIndex, Key? key})
      : super(key: key);

  final int getIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CardToolListWidgetState();
}

//NEEDS TO BE REDONE

class _CardToolListWidgetState extends ConsumerState<CardToolListWidget> {
  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardListProvider);
    var currentCard = cards[widget.getIndex];
    final dateParts = currentCard.creationDate.split(', ');
    final dateOnly = dateParts[1];
    final newFormat = DateFormat('MM/dd/yyyy');
    final parsedDate = newFormat.parse(dateOnly);
    final month = parsedDate.month;

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: .5)),
        child: Row(children: [
          Container(
            decoration: BoxDecoration(
              color: PaycheckMonthModel.getColorForMonth(month),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            width: 30,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: BorderSide.strokeAlignCenter),
                            maximumSize: const Size(80, 45),
                            backgroundColor: const Color(0xFFD5E8FA),
                            foregroundColor: Colors.blue.shade800,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    width: 1, color: Colors.black12))),
                        onPressed: () async {
                          await showModalBottomSheet(
                            showDragHandle: true,
                            isDismissible: false,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            context: context,
                            builder: (context) => EditCardModel(
                              cardToUpdate: currentCard,
                              oncardUpdated: (card) {
                                setState(() {
                                  currentCard = card;
                                });
                              },
                            ),
                          );
                        },
                        child: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(
                        currentCard.cardTitle,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        currentCard.description,
                        maxLines: 1,
                      ),
                      trailing: Transform.scale(
                        scale: 1.2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      showDragHandle: true,
                                      isDismissible: false,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      context: context,
                                      builder: (context) => CardDetails(
                                          selectedCard: CardModel(
                                              cardTitle: '',
                                              description: '',
                                              creationDate: '',
                                              amount: '')),
                                    );
                                  },
                                  style: ButtonStyle(
                                    fixedSize: MaterialStatePropertyAll(
                                      Size(
                                          MediaQuery.of(context).size.width /
                                              5.8,
                                          MediaQuery.of(context).size.height /
                                              22),
                                    ),
                                    backgroundColor:
                                        const MaterialStatePropertyAll(
                                            Color(0xFFD5E8FA)),
                                    foregroundColor: MaterialStatePropertyAll(
                                        Colors.blue.shade800),
                                    elevation:
                                        const MaterialStatePropertyAll(0),
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: const BorderSide(
                                                width: 1,
                                                color: Colors.black12))),
                                  ),
                                  child: const Text(
                                    'Details',
                                    style: TextStyle(fontSize: 12),
                                  )),
                            ],
                          ),
                        ),
                      )),
                  Transform.translate(
                    offset: const Offset(0, -12),
                    child: Column(
                      children: [
                        const Divider(
                          thickness: 1.5,
                          color: Colors.black38,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(children: [
                              if (currentCard.creationDate == 'mm/dd/yy')
                                const Text('No Date set')
                              else if (currentCard.creationDate != 'mm/dd/yy')
                                Text(currentCard.creationDate)
                            ]),
                            Column(
                              children: [
                                Text('Amount: \$${currentCard.amount}'),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ]),
          ))
        ]));
  }
}

Future<List<String>> loadArray(CardModel paycheck) async {
  final userID = FirebaseAuth.instance.currentUser?.uid;
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('Cards')
        .doc(paycheck.docID)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null &&
          data.containsKey('repeatingDays') &&
          data['repeatingDays'] is List<dynamic>) {
        var repeatingDaysArray = data['repeatingDays'] as List<dynamic>;

        List<String> array = [];

        for (var day in repeatingDaysArray) {
          if (day is String) {
            array.add(day);
          }
        }

        return array;
      }
    }

    return [];
  } catch (e) {
    return [];
  }
}
