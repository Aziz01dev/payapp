import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  DateTime _selectedDate = DateTime.now();
  String _percentageText = "0 %";

  @override
  void initState() {
    super.initState();
    payappViewModel.getDates();
    if (widget.oldAmount != null) {
      nameController.text = widget.oldAmount!.title;
      amountController.text = widget.oldAmount!.price.toString();
      dayController.text = widget.oldAmount!.day;
    }
    cardpriceController.addListener(_calculatePercentage);
  }

  void _calculatePercentage() {
    final value = int.tryParse(cardpriceController.text.trim()) ?? 0;
    final percentage = (value * 0.2).toInt();
    setState(() {
      _percentageText = "$percentage";
    });
  }

  void showCalendar() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      initialDate: _selectedDate,
    );
    if (result != null) {
      setState(() {
        _selectedDate = result;
        dayController.text = DateFormat('yyyy-MM-dd').format(result);
      });
    }
  }

  void goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  List<PayAppModel> getFilteredItems() {
    final selectedDateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return payappViewModel.nextItem.where((item) {
      return item.day.startsWith(selectedDateString);
    }).toList();
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final title = nameController.text.trim();
      final day = dayController.text.trim();
      final price = int.tryParse(amountController.text.trim()) ?? 0;
      print("Saving: title=$title, price=$price, day=$day");
      if (widget.oldAmount == null) {
        final success = await payappViewModel.addItem(
          title: title,
          price: price,
          day: day,
        );
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Xarajat qo‘shishda xato yuz berdi")),
          );
        }
      } else {
        final updatedItem = widget.oldAmount!.copyWith(
          title: title,
          price: price,
          day: day,
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

  void _showSearch() {
    showSearch(
      context: context,
      delegate: PayAppSearchDelegate(
        payappViewModel.nextItem,
        onItemTapped: (item) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage(oldAmount: item)),
          );
        },
      ),
    );
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
        title: GestureDetector(
          onTap: showCalendar,
          child: Text(
            DateFormat('MMMM, yyyy').format(_selectedDate),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: goToPreviousDay,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch, // Qidiruvni ochish
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: goToNextDay,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 80, top: 40),
              child: Text(
                "${cardpriceController.text} so'm",
                style: const TextStyle(fontSize: 30),
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
                            const Text("Balans"),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: cardpriceController,
                              decoration: const InputDecoration(
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
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {});
                                      Navigator.pop(context);
                                    }
                                  },
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
                        const Spacer(),
                        Text(
                          _percentageText,
                          style: const TextStyle(color: Colors.white),
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
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: getFilteredItems().length,
                    itemBuilder: (context, index) {
                      final item = getFilteredItems()[index];
                      return Dismissible(
                        onDismissed: (direction) {
                          payappViewModel.deleteItem(item.id);
                        },
                        background: Container(
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete),
                          alignment: Alignment.centerRight,
                        ),
                        key: Key(item.id.toString()),
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

class PayAppSearchDelegate extends SearchDelegate {
  final List<PayAppModel> items;
  final Function(PayAppModel) onItemTapped;

  PayAppSearchDelegate(this.items, {required this.onItemTapped});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        items.where((item) {
          return item.title.toLowerCase().contains(query.toLowerCase());
        }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.day),
          trailing: Text("${item.price} so'm"),
          onTap: () {
            onItemTapped(item);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        items.where((item) {
          return item.title.toLowerCase().contains(query.toLowerCase());
        }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.day),
          trailing: Text("${item.price} so'm"),
          onTap: () {
            onItemTapped(item);
          },
        );
      },
    );
  }
}
