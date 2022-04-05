import 'package:flutter/material.dart';
import 'package:passman/model/password_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PasswordTile extends StatelessWidget {
  final PasswordItem passItem;
  final Function(PasswordItem ps) itemDetail;

  const PasswordTile({Key? key, required this.passItem, required this.itemDetail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        itemDetail(passItem);
        },
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.url + ":"),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(passItem.url!),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.username + ":"),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(passItem.username!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
