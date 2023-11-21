import 'package:flutter/material.dart';

import 'gzx_dropdown_menu_controller.dart';

/// Signature for when a tap has occurred.
typedef OnItemTap<T> = void Function(T value);

/// Dropdown header widget.
class GZXDropDownHeader extends StatefulWidget {
  final Color? color;
  final double borderWidth;
  final Color? borderColor;
  final TextStyle style;
  final TextStyle? dropDownStyle;
  final double iconSize;
  final Color? iconColor;
  final Color? iconDropDownColor;
  final double height;
  final double dividerHeight;
  final Color? dividerColor;
  final GZXDropdownMenuController controller;
  final OnItemTap? onItemTap;
  final List<GZXDropDownHeaderItem> items;
  final GlobalKey stackKey;

  /// Creates a dropdown header widget, Contains more than one header items.
  const GZXDropDownHeader(
      {super.key,
      required this.items,
      required this.controller,
      required this.stackKey,
      this.style = const TextStyle(color: Color(0xFF666666), fontSize: 13),
      this.dropDownStyle,
      this.height = 40,
      this.iconColor = const Color(0xFFafada7),
      this.iconDropDownColor,
      this.iconSize = 20,
      this.borderWidth = 1,
      this.borderColor,
      this.dividerHeight = 20,
      this.dividerColor,
      this.onItemTap,
      this.color = Colors.white});

  @override
  createState() => _GZXDropDownHeaderState();
}

class _GZXDropDownHeaderState extends State<GZXDropDownHeader> with SingleTickerProviderStateMixin {
  bool _isShowDropDownItemWidget = false;
  late double _screenWidth;
  late int _menuCount;
  final GlobalKey _keyDropDownHeader = GlobalKey();
  TextStyle? _dropDownStyle;
  Color? _iconDropDownColor;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  _onController() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _dropDownStyle = widget.dropDownStyle ?? TextStyle(color: Theme.of(context).primaryColor, fontSize: 13);
    _iconDropDownColor = widget.iconDropDownColor ?? Theme.of(context).primaryColor;

    MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _menuCount = widget.items.length;

    var gridView = GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: _menuCount,
        childAspectRatio: (_screenWidth / _menuCount) / widget.height,
        children: widget.items.map<Widget>((item) {
          return _menu(item);
        }).toList());

    return Container(
        key: _keyDropDownHeader,
        height: widget.height,
        decoration: BoxDecoration(
            border: Border.all(color: widget.borderColor ?? const Color(0xFFeeede6), width: widget.borderWidth)),
        child: gridView);
  }

  _menu(GZXDropDownHeaderItem item) {
    int index = widget.items.indexOf(item);
    int menuIndex = widget.controller.menuIndex;
    _isShowDropDownItemWidget = index == menuIndex && widget.controller.isShow;

    return GestureDetector(
        onTap: () {
          final RenderBox? overlay = widget.stackKey.currentContext!.findRenderObject() as RenderBox?;

          final RenderBox dropDownItemRenderBox = _keyDropDownHeader.currentContext!.findRenderObject() as RenderBox;

          var position = dropDownItemRenderBox.localToGlobal(Offset.zero, ancestor: overlay);
          var size = dropDownItemRenderBox.size;

          widget.controller.dropDownMenuTop = size.height + position.dy;

          if (index == menuIndex) {
            if (widget.controller.isShow) {
              widget.controller.hide();
            } else {
              widget.controller.show(index);
            }
          } else {
            if (widget.controller.isShow) {
              widget.controller.hide(isShowHideAnimation: false);
            }
            widget.controller.show(index);
          }

          if (widget.onItemTap != null) {
            widget.onItemTap!(index);
          }

          setState(() {});
        },
        child: Container(
            color: widget.color,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Flexible(
                      child: Text(item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _isShowDropDownItemWidget ? _dropDownStyle : widget.style.merge(item.style))),
                  Icon(
                      !_isShowDropDownItemWidget
                          ? item.iconData ?? Icons.keyboard_arrow_down
                          : item.iconDropDownData ?? item.iconData ?? Icons.keyboard_arrow_up,
                      color: _isShowDropDownItemWidget ? _iconDropDownColor : item.style?.color ?? widget.iconColor,
                      size: item.iconSize ?? widget.iconSize)
                ]),
              ),
              index == widget.items.length - 1
                  ? const SizedBox()
                  : Container(
                      height: widget.dividerHeight,
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(color: widget.dividerColor ?? const Color(0xFFeeede6), width: 1))))
            ])));
  }
}

class GZXDropDownHeaderItem {
  final String title;
  final IconData? iconData;
  final IconData? iconDropDownData;
  final double? iconSize;
  final TextStyle? style;

  GZXDropDownHeaderItem(this.title, {this.iconData, this.iconDropDownData, this.iconSize, this.style});
}
