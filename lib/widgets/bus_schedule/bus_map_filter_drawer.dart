import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/bus_provider.dart';
import '../../utils/app_localization.dart';

class BusMapFilterDrawer extends StatefulWidget {
  final Function onPressAnimate;

  const BusMapFilterDrawer({
    required this.onPressAnimate,
    super.key,
  });

  @override
  State<BusMapFilterDrawer> createState() => _BusMapFilterDrawerState();
}

class _BusMapFilterDrawerState extends State<BusMapFilterDrawer> {
  late String selectedRadio;
  late String routeName;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    selectedRadio = Provider.of<BusProvider>(context).routeId!;
    routeName = 'SD';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Drawer(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: Consumer<BusProvider>(
          builder: (_, busData, __) {
            return Stack(
              children: [
                Column(
                  children: <Widget>[
                    Container(
                      height: screenSize.height * 0.11,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0.3,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(
                        bottom: 1.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalization.of(context)!.translate('choose_l')!,
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize,
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              AppLocalization.of(context)!.translate('cancel')!,
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .fontSize,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      width: screenSize.width * 0.6,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        boxShadow: [
                          // to make elevation
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset(2, 1.5),
                            blurRadius: 5,
                          ),
                          // to make the coloured border
                          BoxShadow(
                            color: Colors.purple,
                            offset: Offset(-6.5, 2.5),
                          ),
                        ],
                      ),
                      height: screenSize.height * 0.05,
                      child: Text(
                        AppLocalization.of(context)!
                            .translate('103_bus_route')!,
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleMedium!.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ...busData.busRouteList.map((e) => ListTile(
                          onTap: () {
                            setState(() {
                              selectedRadio = e.routeId;
                              routeName = e.routeName;
                            });
                          },
                          leading: Radio(
                            activeColor: Theme.of(context).primaryColor,
                            value: e.routeId,
                            groupValue: selectedRadio,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (value) {
                              setState(() {
                                selectedRadio = value.toString();
                                routeName = e.routeName;
                              });
                            },
                          ),
                          title: Text(
                            e.routeName == 'DS'
                                ? 'DUN > Semenggoh'
                                : 'Semenggoh > DUN',
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .fontSize,
                            ),
                          ),
                        )),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 50,
                  child: Align(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 10.0,
                        ),
                      )),
                      onPressed: () {
                        if (Provider.of<BusProvider>(context, listen: false)
                                .routeId !=
                            selectedRadio.toString()) {
                          Provider.of<BusProvider>(context, listen: false)
                              .changeRouteProvider(
                            selectedRadio.toString(),
                            routeName,
                          );
                          Navigator.of(context).pop();
                          widget.onPressAnimate();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        AppLocalization.of(context)!.translate('choose')!,
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleMedium!.fontSize,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
