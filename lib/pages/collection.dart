import 'package:dailypics/misc/bean.dart';
import 'package:dailypics/model/app.dart';
import 'package:dailypics/utils/api.dart';
import 'package:dailypics/utils/utils.dart';
import 'package:dailypics/widget/slivers.dart';
import 'package:flutter/cupertino.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();

  static Future<void> push(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(builder: (_) => CollectionPage()),
    );
  }
}

class _CollectionPageState extends State<CollectionPage> {
  ScrollController controller = ScrollController();

  List<Picture> data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((_) => _fetchData());
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (data == null) {
      result = const Center(
        child: CupertinoActivityIndicator(),
      );
    } else {
      result = CupertinoScrollbar(
        controller: controller,
        child: CustomScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: const Text('我的收藏'),
              padding: EdgeInsetsDirectional.zero,
              leading: CupertinoButton(
                child: Icon(CupertinoIcons.back),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            CupertinoSliverRefreshControl(onRefresh: _fetchData),
            SliverSafeArea(
              top: false,
              sliver: SliverImageCardList(
                tagBuilder: (i) => '$i-${data[i].id}',
                data: data,
              ),
            ),
          ],
        ),
      );
    }
    return CupertinoPageScaffold(
      child: result,
    );
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    List<Picture> saved = AppModel.of(context).collections;
    if (saved.isNotEmpty) {
      setState(() => data = saved);
    } else {
      List<Picture> result = [];
      List<String> ids = Settings.marked;
      for (int i = 0; i < ids.length; i++) {
        result.add(await TujianApi.getDetails(ids[i]));
      }
      AppModel.of(context).collections = result;
      setState(() => data = result);
    }
  }
}
