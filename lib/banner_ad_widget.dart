import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
	const BannerAdWidget({Key? key}) : super(key: key);

	@override
	State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
	BannerAd? _bannerAd;
	bool _isLoaded = false;

	@override
	void initState() {
		super.initState();
		_bannerAd = BannerAd(
			adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test AdMob Banner ID
			size: AdSize.banner,
			request: AdRequest(),
			listener: BannerAdListener(
				onAdLoaded: (ad) {
					setState(() {
						_isLoaded = true;
					});
				},
				onAdFailedToLoad: (ad, error) {
					ad.dispose();
				},
			),
		)..load();
	}

	@override
	void dispose() {
		_bannerAd?.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		if (_isLoaded && _bannerAd != null) {
			return Container(
				alignment: Alignment.center,
				width: _bannerAd!.size.width.toDouble(),
				height: _bannerAd!.size.height.toDouble(),
				child: AdWidget(ad: _bannerAd!),
			);
		} else {
			return const SizedBox.shrink();
		}
	}
}
