import 'package:car_manufac/car_mfr.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  CarMfr? carMfr;

  Future<CarMfr?> getCarMfr() async {
    var url = "vpic.nhtsa.dot.gov";

    var uri = Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    await Future.delayed(const Duration(seconds: 3));
    var response = await get(uri);

    carMfr = carMfrFromJson(response.body);
    return carMfr;
  }

  @override
  void initState() {
    super.initState();
    getCarMfr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<CarMfr?>(
        future: getCarMfr(),
        builder: (BuildContext context, AsyncSnapshot<CarMfr?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              var results = snapshot.data!.results ?? [];
              return ListView.builder(
                itemCount: results.length,
                padding: const EdgeInsets.all(10.0),
                itemBuilder: (context, index) {
                  var item = results[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        item.mfrName ?? "Unknown Manufacturer",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "Country: ${item.country ?? "N/A"}",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green,
                      ),
                      onTap: () {
                        // กดที่รายการเพื่อดูรายละเอียดเพิ่มเติม
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(item.mfrName ?? "Details"),
                            content: Text(
                              "Manufacturer Name: ${item.mfrName ?? "N/A"}\nCountry: ${item.country ?? "N/A"}",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text("No data available."));
            }
          }
          return const Center(child: Text("An error occurred while loading data."));
        },
      ),
    );
  }
}
