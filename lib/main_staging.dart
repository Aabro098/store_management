import 'package:finco_customer/config/flavor_config.dart';
import 'package:finco_customer/main.dart';
import 'package:finco_customer/utils/constants/api_constants.dart';

Future<void> main() async {
  FlavorConfig.initialize(
    flavor: Flavor.staging,
    appName: 'Sushmita Electronics Staging',
    baseUrl: UrlStrings.baseUrlStaging,
  );
  await bootstrap();
}
