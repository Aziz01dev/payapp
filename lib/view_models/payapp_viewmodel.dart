import 'package:pay_app/models/pay_app_model.dart';
import 'package:pay_app/services/local_database.dart';

class PayappViewModel {
  PayappViewModel._privateConstructor();
  static final PayappViewModel _instance =
      PayappViewModel._privateConstructor();

  factory PayappViewModel() => _instance;

  final LocalDatabase _localDatabase = LocalDatabase();
  List<PayAppModel> nextItem = [];

  Future<void> init() async {
    await _localDatabase.init();
    await getDates();
  }

  Future<void> getDates() async {
    nextItem = await _localDatabase.get();
  }

  Future<void> addItem({
    required String title,
    required int price,
    required String day,
  }) async {
    try {
      final newItem = PayAppModel(id: 0, title: title, price: price, day: day);
      final id = await _localDatabase.insert(newItem);
      nextItem.add(newItem.copyWith(id: id));
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  Future<void> editApp(PayAppModel item) async {
    try {
      await _localDatabase.update(item);
      final index = nextItem.indexWhere((t) => t.id == item.id);
      if (index != -1) {
        nextItem[index] = item;
      }
    } catch (e) {
      print("Error editing item: $e");
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _localDatabase.delete(id);
      nextItem.removeWhere((t) => t.id == id);
    } catch (e) {
      print("Error deleting item: $e");
    }
  }
}
