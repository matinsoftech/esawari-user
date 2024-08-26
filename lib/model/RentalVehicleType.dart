class RentalVehicleType {
  String? rentalVehicleIcon;
  String? shortDescription;
  String? name;
  String? description;
  String? id;
  bool? isActive;
  String? supportedVehicle;
  String? capacity;

  RentalVehicleType({this.rentalVehicleIcon, this.shortDescription, this.name, this.description, this.id, this.isActive, this.supportedVehicle, this.capacity});

  RentalVehicleType.fromJson(Map<String, dynamic> json) {
    rentalVehicleIcon = json['rental_vehicle_icon'];
    shortDescription = json['short_description'];
    name = json['name'];
    description = json['description'];
    id = json['id'];
    isActive = json['isActive'];
    supportedVehicle = json['supported_vehicle'];
    capacity = json['capacity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rental_vehicle_icon'] = rentalVehicleIcon;
    data['short_description'] = shortDescription;
    data['name'] = name;
    data['description'] = description;
    data['id'] = id;
    data['isActive'] = isActive;
    data['supported_vehicle'] = supportedVehicle;
    data['capacity'] = capacity;
    return data;
  }
}
