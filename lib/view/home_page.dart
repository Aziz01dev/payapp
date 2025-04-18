import 'package:flutter/material.dart';
import 'package:pay_app/models/pay_app_model.dart';
import 'package:pay_app/view_models/payapp_viewmodel.dart';

class HomePage extends StatefulWidget {
  final PayAppModel? oldAmount;
  const HomePage({super.key, this.oldAmount});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final payappViewModel = PayappViewModel();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final dayController = TextEditingController();
  final cardpriceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    payappViewModel.getDates();
    if (widget.oldAmount != null) {
      nameController.text = widget.oldAmount!.title;
      amountController.text = widget.oldAmount!.price.toString();
      dayController.text = widget.oldAmount!.day;
      cardpriceController.text = widget.oldAmount!.cardprice;
    }
  }

  void showCalendar() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
    );
    if (result != null) {
      dayController.text = result.toString();
    }
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final title = nameController.text.trim();
      final day = dayController.text.trim();
      final cardprice = cardpriceController.text.trim();
      final price = int.tryParse(amountController.text.trim()) ?? 0;
      if (widget.oldAmount == null) {
        await payappViewModel.addItem(
          title: title,
          price: price,
          day: day,
          cardprice: cardprice,
        );
      } else {
        final updatedItem = widget.oldAmount!.copyWith(
          title: title,
          price: price,
          day: day,
          cardpice: cardprice,
        );
        await payappViewModel.editApp(updatedItem);
      }
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    dayController.dispose();
    cardpriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fevral, 2025"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 80, top: 40),
              child: Text(
                "${cardpriceController.text} so'm",
                style: TextStyle(fontSize: 30),
              ),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Balans"),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: cardpriceController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Miqdor",
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Iltimos miqdorni kiriting";
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return "Faqat raqam kiriting";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Bekor qilish"),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : save,
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text("Saqlash"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 24, 190, 255),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          "${cardpriceController.text} %",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.blueGrey, thickness: 6),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 62, 214, 31),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Amalyotlar",
                        style: TextStyle(color: Colors.pink),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          nameController.clear();
                          amountController.clear();
                          dayController.clear();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Harajat nomi",
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Iltimos nomni kiriting";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller: amountController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Harajat miqdori",
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Iltimos miqdorni kiriting";
                                          }
                                          if (int.tryParse(value.trim()) ==
                                              null) {
                                            return "Faqat raqam kiriting";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller: dayController,
                                        readOnly: true,
                                        onTap: showCalendar,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Muddati",
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Iltimos muddatni kiriting";
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Bekor qilish"),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading ? null : save,
                                    child:
                                        _isLoading
                                            ? const CircularProgressIndicator()
                                            : const Text("Saqlash"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: payappViewModel.nextItem.length,
                    itemBuilder: (context, index) {
                      final item = payappViewModel.nextItem[index];
                      return Dismissible(
                        onDismissed: (direction) {
                          payappViewModel.deleteItem(
                            payappViewModel.nextItem[index].id,
                          );
                        },
                        background: Container(
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: Icon(Icons.delete),
                          alignment: Alignment.centerRight,
                        ),
                        key: Key(index.toString()),
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.day),
                          trailing: Text("${item.price} so'm"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(oldAmount: item),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
