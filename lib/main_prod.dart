import 'package:finco_customer/config/flavor_config.dart';
import 'package:finco_customer/main.dart';
import 'package:finco_customer/utils/constants/api_constants.dart';

Future<void> main() async {
  FlavorConfig.initialize(
    flavor: Flavor.prod,
    appName: 'Sushmita Electronics',
    baseUrl: UrlStrings.baseUrlProd,
  );
  await bootstrap();
}
