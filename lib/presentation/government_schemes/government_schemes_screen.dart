import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class GovernmentSchemesScreen extends StatelessWidget {
  const GovernmentSchemesScreen({super.key});

  List<Map<String, String>> get _schemes => const [
    {
      'title': 'Rashtriya Gokul Mission',
      'description':
      'Development and conservation of indigenous cattle breeds.',
      'url':
      'https://dahd.nic.in/schemes/rashtriya-gokul-mission',
    },
    {
      'title': 'National Livestock Mission',
      'description':
      'Increase productivity and entrepreneurship in livestock.',
      'url':
      'https://dahd.nic.in/schemes/national-livestock-mission',
    },
    {
      'title': 'Dairy Entrepreneurship Development Scheme',
      'description':
      'Financial assistance for setting up dairy farms.',
      'url':
      'https://www.nabard.org/content1.aspx?id=592&catid=23&mid=23',
    },
    {
      'title': 'Livestock Insurance Scheme',
      'description':
      'Insurance coverage to protect farmers against cattle loss.',
      'url':
      'https://dahd.nic.in/schemes/livestock-insurance-scheme',
    },
    {
      'title': 'Kisan Credit Card – Animal Husbandry',
      'description':
      'Easy credit access for dairy and livestock farmers.',
      'url':
      'https://www.myscheme.gov.in/schemes/kcc-ah',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government Schemes')),
      body: ListView.separated(
        padding: EdgeInsets.all(4.w),
        itemCount: _schemes.length,
        separatorBuilder: (_, __) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          final scheme = _schemes[index];

          return Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme['title']!,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                  SizedBox(height: 1.h),
                  Text(scheme['description']!),
                  SizedBox(height: 2.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.schemeWebView,
                          arguments: {
                            'title': scheme['title']!,
                            'url': scheme['url']!,
                          },
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
