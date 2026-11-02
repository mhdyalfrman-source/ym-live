import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ionicons_plus/ionicons_plus.dart';
import 'package:tom_chat/l10n/l10n.dart';

class SearchBox extends StatefulWidget {
  final Function(String) onSubmitted;
  final void Function() onFilter;
  final void Function() onStart;
  final void Function() onEnd;
  final TextEditingController controller;
  final FocusNode node;
  final String searchTitle;
  const SearchBox({
    super.key,
    required this.onSubmitted,
    required this.onFilter,
    required this.onStart,
    required this.onEnd,
    required this.controller,
    required this.node,
    required this.searchTitle,
  });

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  bool isEmpty = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(
              0.1,
            ), //headColor.withOpacity(0.3),
            offset: const Offset(1, 1),
            blurRadius: 5,
          ),
        ],
        color: Theme.of(context).scaffoldBackgroundColor, //cardColor
        borderRadius: BorderRadius.circular(10).r,
      ),
      // height: AppBar().preferredSize.height,
      child: TextFormField(
        onTapOutside: (v) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: Theme.of(context).textTheme.displaySmall,
        // onTap: onStart,
        // onEditingComplete: onEnd,
        focusNode: widget.node,
        cursorRadius: const Radius.circular(10),
        textDirection: TextDirection.rtl,
        onChanged: (v) {
          setState(() {
            isEmpty = v.trim().isEmpty;
          });
        },
        onFieldSubmitted: widget.onSubmitted,
        keyboardType: TextInputType.text,
        controller: widget.controller,
        // style: const TextStyle(
        //     color: Colors.black),
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: Icon(Ionicons.search),
            onPressed: () async {
              // widget.onSubmitted(widget.controller.text);
              await widget.onSubmitted(widget.controller.text);
            },
          ),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          hintText: widget.searchTitle,
          hintStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColorDark,
            // for label TextFailed
          ),
        ),
        validator: (v) {
          if (v!.trim() == "") {
            return context.l10n.emptyValue;
          }
          return null;
        },
      ),
    );
  }
}
