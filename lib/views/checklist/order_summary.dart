import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/auth/auth_page.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/explorer/explorer.dart';
import 'package:inventory/views/shared.dart';
import 'package:printing/printing.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/inner_models/barrel.dart';
import '../../tools/assets.dart';
import '../../tools/urls.dart';

class OrderSummary extends StatefulWidget {
  const OrderSummary(this.order, {this.sig, super.key});
  final Order order;
  final Uint8List? sig;

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  // final controller = Get.find<AppController>();
  final imageController = WidgetsToImageController();
  final frameId = "archpage";
  bool isSaving = false;
  // ExportDelegate exd = ExportDelegate(
  //   ttfFonts: {
  //     "Raleway": "assets/fonts/Raleway-Regular.ttf",
  //   },
  //     options: ExportOptions(
  //         textFieldOptions: TextFieldOptions.uniform(
  //           interactive: false,
  //         ),
  //         checkboxOptions: CheckboxOptions.uniform(
  //           interactive: false,
  //         ),

  //         pageFormatOptions: PageFormatOptions.a4()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar:
      // AppBar(
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 32.0),
      //       child: GestureDetector(
      //           onTap: () async {
      //             setState(() {
      //               isSaving = true;
      //             });
      //             final pdf = await imageController.capture();
      //             await controller.saveFile(pdf!, 'static-example');
      //             setState(() {
      //               isSaving = false;
      //             });
      //           },
      //           child: CircleAvatar(
      //               backgroundColor: AppColors.primaryColor,
      //               radius: 24,
      //               child: Center(
      //                   child: AppIcon(
      //                 Icons.print,
      //                 color: AppColors.white,
      //               )))),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.only(right: 32.0),
      //       child: GestureDetector(
      //           onTap: () {
      //             Get.to(CustomOrderPDFPage());
      //             // setState(() {
      //             //   isSaving = true;
      //             // });
      //             // final pdf = await imageController.capture();
      //             // await controller.saveFile(pdf!, 'static-example');
      //             // setState(() {
      //             //   isSaving = false;
      //             // });
      //           },
      //           child: CircleAvatar(
      //               backgroundColor: AppColors.primaryColor,
      //               radius: 24,
      //               child: Center(
      //                   child: AppIcon(
      //                 Icons.upload,
      //                 color: AppColors.green,
      //               )))),
      //     )
      //   ],
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: WidgetsToImage(
          controller: imageController,
          child: Builder(builder: (context) {
            final title = widget.order.isDispatched
                ? "Dispatch Order Summary"
                : "Service Order Summary";
            final toreturn = Column(
              children: [
                LogoWidget(144),
                AppText.medium(title,
                    fontSize: 32,
                    alignment: TextAlign.center,
                    fontFamily: Assets.appFontFamily2),
                Ui.boxHeight(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          Get.off(ChoosePage());
                        },
                        child: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            radius: 24,
                            child: Center(
                                child: AppIcon(
                              Icons.home_outlined,
                              color: AppColors.white,
                            )))),
                    if(widget.order.id == 0)
                    Ui.boxWidth(16),
                    if(widget.order.id == 0)
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            radius: 24,
                            child: Center(
                                child: AppIcon(
                              Icons.mode_edit_outlined,
                              color: AppColors.white,
                            )))),
                    Ui.boxWidth(16),
                    InkWell(
                        onTap: () {
                          Get.to(CustomOrderPDFPage(
                            title,
                            DateTime.now(),
                            order: widget.order,
                            sigUint: widget.sig,
                          ));
                        },
                        child: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            radius: 24,
                            child: Center(
                                child: AppIcon(
                              Icons.download_rounded,
                              color: AppColors.white,
                            )))),
                    Ui.boxWidth(16),
                    InkWell(
                        onTap: () {
                          Get.to(CustomOrderPDFPage(
                            title,
                            DateTime.now(),
                            order: widget.order,
                            sigUint: widget.sig,
                          ));
                        },
                        child: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            radius: 24,
                            child: Center(
                                child: AppIcon(
                              Icons.print_outlined,
                              color: AppColors.white,
                            )))),
                  ],
                ),
                Ui.boxHeight(24),
                serviceItem(
                    "CUSTOMER",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleValueText("Full Name",
                            widget.order.customerDetails?.fullName),
                        titleValueText(
                            "Email", widget.order.customerDetails?.email),
                        titleValueText("Phone Number",
                            widget.order.customerDetails?.phone),
                        titleValueText("Customer Type",
                            widget.order.customerDetails?.customerType),
                      ],
                    )),
                serviceItem(
                    "VEHICLE",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleValueText("Make", widget.order.customerCar?.make),
                        titleValueText(
                            "Model", widget.order.customerCar?.model),
                        titleValueText("Year", widget.order.customerCar?.year),
                        titleValueText("License Plate No",
                            widget.order.customerCar?.licenseNo),
                        titleValueText(
                            "Chassis No", widget.order.customerCar?.chassisNo),
                      ],
                    )),
                serviceItem(
                    "CONCERNS",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.thin(widget.order.customerConcerns ?? "")
                      ],
                    )),
                serviceItem(
                    "VEHICLE CONDTION",
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleValueText("Mileage At Reception",
                            widget.order.mileageOnReception.toString()),
                        titleValueText(
                            "Fuel Level At Reception", widget.order.fuelLevel),
                        titleValueText(
                            "Visible Damage ", widget.order.bodyCheck),
                        titleValueText("Additonal Observations",
                            widget.order.observations),
                      ],
                    )),
                serviceItem(
                    "SERVICE PLAN",
                    SizedBox(
                      height: 100,
                      child: Wrap(
                        direction: Axis.vertical,
                        children: widget.order.allServices
                            .map((e) => AppText.thin(e.name))
                            .toList(),
                      ),
                    )),
                serviceItem("CONTROL CHECKS", Builder(builder: (context) {
                  List<Widget> controlChecks = [];
                  Get.find<AppController>().inspectionNo.forEach((key, value) {
                    controlChecks.add(Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold(key),
                        ...List.generate(
                            value.length,
                            (index) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText.thin(value[index].title),
                                    Ui.boxWidth(4),
                                    widget.order.conditions[
                                                value[index].rawId] ==
                                            1
                                        ? AppIcon(
                                            Icons.check,
                                            color: AppColors.green,
                                            size: 16,
                                          )
                                        : AppIcon(
                                            Icons.close,
                                            color: AppColors.primaryColor,
                                            size: 16,
                                          )
                                  ],
                                ))
                      ],
                    ));
                  });

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: controlChecks,
                  );
                })),
                Ui.boxHeight(24),
                if(widget.order.id == 0)
                SizedBox(
                  width: wideUi(context),
                  child: AppButton(
                    onPressed: () {
                      Get.dialog(AppDialog.normal("Submit Service Order",
                          "Are youy sure you want to submit this service order ?, NB: this will send an email to the customer if any email was provided.",
                          titleA: "Yes", titleB: "No", onPressedA: () async {
                        await Get.find<AppController>().submitServiceOrder();
                      }, onPressedB: () {
                        Get.back();
                      }));
                    },
                    text: "Submit",
                  ),
                )
                // serviceItem(
                //     "MAINTENANCE",
                //     Column(
                //       mainAxisSize: MainAxisSize.min,
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         titleValueText(
                //             "Urgent Maintenance", controller.tecs[19].text),
                //         titleValueText(
                //             "Before Next Visit", controller.tecs[20].text),
                //         titleValueText("During Next Maintenance Service ",
                //             controller.tecs[21].text),
                //         titleValueText(
                //             "Delivery hour Forecast", controller.tecs[21].text),
                //       ],
                //     )),
              ],
            );

            // if(isSaving){
            return Container(
              decoration: BoxDecoration(
                  color: AppColors.white,
                  image: DecorationImage(
                    image: AssetImage(Assets.backg),
                    repeat: ImageRepeat.repeat,
                    opacity: 0.08,
                  )),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: toreturn,
              ),
            );
            // }
            // return toreturn;
          }),
        ),
      ),
    );
  }

  serviceItem(String title, Widget item) {
    return CurvedContainer(
      radius: 16,
      padding: EdgeInsets.only(left: 24),
      margin: EdgeInsets.only(bottom: 24),
      color: AppColors.primaryColor.withOpacity(0.5),
      child: Row(
        children: [
          SizedBox(
              width: Ui.width(context) / 4,
              child: Center(
                  child: AppText.bold(title,
                      fontSize: 24,
                      att: true,
                      color: AppColors.black,
                      alignment: TextAlign.center))),
          Ui.boxWidth(24),
          Expanded(
              child: CurvedContainer(
                  padding: EdgeInsets.all(16),
                  border: Border.all(color: AppColors.primaryColor),
                  color: AppColors.white,
                  child: item))
        ],
      ),
    );
  }

  titleValueText(String key, String? value) {
    // if(value.isEmpty) return const SizedBox();
    return Text.rich(TextSpan(
        text: "$key : ",
        style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontFamily: Assets.appFontFamily),
        children: [
          TextSpan(
            text: value ?? "",
            style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w400,
                fontFamily: Assets.appFontFamily,
                fontSize: 16),
          )
        ]));
    // return Row(
    //   children: [AppText.bold("$key :"), Ui.boxWidth(8), AppText.thin(value)],
    // );
  }
}

class CustomOrderPDFPage extends StatefulWidget {
  const CustomOrderPDFPage(this.title, this.orderDate,
      {this.orderFinished, required this.order, this.sigUint, super.key});
  final DateTime orderDate;
  final DateTime? orderFinished;
  final String title;
  final Order order;
  final Uint8List? sigUint;

  @override
  State<CustomOrderPDFPage> createState() => _CustomOrderPDFPageState();
}

class _CustomOrderPDFPageState extends State<CustomOrderPDFPage> {
  late pw.Font defFontReg, defFontMedium, defFontBold, segoe;
  late pw.ImageProvider logo, bg;
  pw.ImageProvider? sig;
  pw.Document? cpdf;

  @override
  void initState() {
    initItems();
    super.initState();
  }

  initItems() async {
    logo = await imageFromAssetBundle(Assets.logoWhite);
    bg = await imageFromAssetBundle(Assets.backg);
    defFontReg = await fontFromAssetBundle(Assets.appFontFamilyRegular);
    defFontBold = await fontFromAssetBundle(Assets.appFontFamilyBold);
    defFontMedium = await fontFromAssetBundle(Assets.appFontFamilyMedium);
    segoe = await fontFromAssetBundle(Assets.appFontFamilySegoe);
    if (widget.order.customerDetails?.signature.isNotEmpty ?? false) {
      sig = await networkImage("${AppUrls.baseURL}${AppUrls.upload}/all/${widget.order.customerDetails!.signature}");
    }
    if (widget.sigUint != null && (widget.sigUint?.isNotEmpty ?? false)) {
      sig = pw.MemoryImage(widget.sigUint!);
    }
    await doPDFPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: cpdf == null
            ? Center(child: LoadingIndicator())
            : PdfPreview(
                actionBarTheme:
                    PdfActionBarTheme(backgroundColor: AppColors.primaryColor),
                pdfFileName: "ServiceOrderSummary.pdf",
                build: (f) => cpdf!.save()));
  }

  doPDFPage() {
    final pdf = pw.Document();
    // final controller = Get.find<AppController>();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      build: (context) {
        final pf = pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // HEADER
          pw.Row(children: [
            pw.Expanded(child: pw.SizedBox()),
            pw.Expanded(
                child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Image(logo, width: 72, height: 72),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text("MRS Service Station, Alapere,Lagos",
                    style: pw.TextStyle(
                      font: defFontReg,
                      fontSize: 8,
                    )),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text("Service Order Summary",
                    style: pw.TextStyle(
                      font: defFontBold,
                      fontSize: 16,
                    )),
              ),
            ])),
            pw.Expanded(
              child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                            "Generated On : " +
                                DateFormat("dd/MM/yyyy hh:mm:aa")
                                    .format(DateTime.now()),
                            style: pw.TextStyle(
                              font: defFontMedium,
                              fontSize: 8,
                            )),
                        pw.SizedBox(height: 4),
                        pw.Text(
                            "Order Created On : " +
                                DateFormat("dd/MM/yyyy hh:mm:aa")
                                    .format(widget.orderDate),
                            style: pw.TextStyle(
                              font: defFontMedium,
                              fontSize: 8,
                            )),
                        pw.SizedBox(height: 4),
                        if (widget.orderFinished != null)
                          pw.Text(
                              "Order Finished On : " +
                                  DateFormat("dd/MM/yyyy hh:mm:aa")
                                      .format(widget.orderFinished!),
                              style: pw.TextStyle(
                                font: defFontMedium,
                                fontSize: 8,
                              ))
                      ])),
            )
          ]),

          // REGISTRATION SUMMARY
          ...descText("Registration Summary", {
            "Full Name": widget.order.customerDetails?.fullName,
            "Email": widget.order.customerDetails?.email,
            "Phone Number": widget.order.customerDetails?.phone,
            "Customer Type": widget.order.customerDetails?.customerType,
            "Car Details":
                "${widget.order.customerCar?.make} ${widget.order.customerCar?.model} ${widget.order.customerCar?.year}",
            "License Plate No": widget.order.customerCar?.licenseNo,
            "Chassis No": widget.order.customerCar?.chassisNo
          }),

          // CUSTOMER CONCERNS
          ...descText(
              "Customer Concerns", {"Concerns": widget.order.customerConcerns},
              useMaxSize: [true]),

          // VEHICLE CONDITIONS
          ...descText("Vehicle Condtions", {
            "Mileage": widget.order.mileageOnReception.toString(),
            "Fuel Level": widget.order.fuelLevel,
            "Body Check": widget.order.bodyCheck,
            "Additional Observations": widget.order.observations,
          }, useMaxSize: [
            false,
            false,
            true,
            true
          ]),

          //CONTROL CHECKS
          pw.SizedBox(height: 16),
          titleText("Control Checks", hasBottomMargin: true),
          pw.Builder(builder: (context) {
            List<pw.Widget> controlChecks = [];
            Get.find<AppController>().inspectionNo.forEach((key, value) {
              controlChecks.add(pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(key,
                      style: pw.TextStyle(
                        font: defFontMedium,
                        fontSize: 8,
                      )),
                  ...List.generate(value.length, (index) {
                    final ls = widget.order.conditions[value[index].rawId] == 1;
                    return pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(value[index].title,
                            style: pw.TextStyle(
                                font: defFontMedium,
                                fontSize: 8,
                                color: PdfColor.fromInt(0xFF777777))),
                        pw.SizedBox(width: 4),
                        // pw.Icon(pw.IconData(value[index].isChecked ? Icons.check.codePoint : Icons.close.codePoint),size: 8,font: pw.Font.symbol(),color: value[index].isChecked ?PdfColors.green:PdfColors.red)
                        pw.Text(ls ? "+" : "x",
                            style: ls
                                ? pw.TextStyle(
                                    font: segoe,
                                    fontSize: 8,
                                    color: PdfColors.green)
                                : pw.TextStyle(
                                    font: segoe,
                                    fontSize: 8,
                                    color: PdfColors.red))
                      ],
                    );
                  })
                ],
              ));
            });

            return pw.ConstrainedBox(
                constraints: pw.BoxConstraints(maxHeight: 100),
                child: pw.Wrap(
                  direction: pw.Axis.vertical,
                  spacing: 8,
                  runSpacing: 8,
                  children: controlChecks,
                ));
          }),

          // SERVICE
          pw.SizedBox(height: 16),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  titleText("Service Plans", hasBottomMargin: true, width: 200),
                  pw.ConstrainedBox(
                    constraints: pw.BoxConstraints(maxHeight: 100),
                    child: pw.Wrap(
                      direction: pw.Axis.vertical,
                      spacing: 4,
                      runSpacing: 16,
                      children: widget.order.allServices
                          .map(
                            (e) => pw.Text("- ${e.name}",
                                style: pw.TextStyle(
                                    font: defFontReg,
                                    fontSize: 8,
                                    color: PdfColor.fromInt(0xFF1E1E1E))),
                          )
                          .toList(),
                    ),
                  ),
                ]),
            pw.Spacer(),
            pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  titleText("Customer/Driver Signature",
                      hasBottomMargin: true, width: 200),
                  pw.Container(
                      height: 32,
                      width: 200,
                      padding: pw.EdgeInsets.only(bottom: 4),
                      decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide())),
                      child: pw.SizedBox(
                          height: 50,
                          width: 200,
                          child: sig == null ? pw.SizedBox() : pw.Image(sig!))),
                  pw.SizedBox(height: 8),
                  pw.Text("Inspected By:  ${widget.order.technician}",
                      style: pw.TextStyle(
                          font: defFontReg,
                          fontSize: 8,
                          color: PdfColor.fromInt(0xFF1E1E1E))),
                  pw.Text("Service Advisor:  ${widget.order.serviceAdvisor}",
                      style: pw.TextStyle(
                          font: defFontReg,
                          fontSize: 8,
                          color: PdfColor.fromInt(0xFF1E1E1E)))
                ]),
          ])
        ]);

        return pw.Stack(
            // overflow: pw.Overflow.clip,
            children: [
              pw.Opacity(
                  opacity: 0.17,
                  child: pw.Image(bg,
                      fit: pw.BoxFit.cover,
                      height: PdfPageFormat.a4.height,
                      width: PdfPageFormat.a4.width)),
              pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: pf)
            ]);
      },
    ));

    setState(() {
      cpdf = pdf;
    });
  }

  pw.Widget titleText(String title,
      {double? width, bool hasBottomMargin = false}) {
    final pf = pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(title,
            style: pw.TextStyle(
              font: defFontMedium,
              color: PdfColors.white,
              fontSize: 12,
            )));
    return pw.Container(
        width: width ?? PdfPageFormat.a4.width - 32,
        margin: hasBottomMargin ? pw.EdgeInsets.only(bottom: 4) : null,
        color: PdfColor.fromInt(AppColors.primaryColor.value),
        child: pf);
  }

  List<pw.Widget> descText(String title, Map<String, String?> mp,
      {List<bool> useMaxSize = const []}) {
    final mapEntry = mp.entries.toList();
    if (useMaxSize.isEmpty) {
      useMaxSize = List.generate(mapEntry.length, (index) => false);
    }
    final fg = [
      pw.SizedBox(height: 16),
      titleText(title),
    ];
    final fgg = List<pw.Widget>.generate(mp.length, (index) {
      final map = mapEntry[index];
      final pwr = pw.Row(children: [
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            padding: pw.EdgeInsets.only(left: 4, top: 2),
            constraints: pw.BoxConstraints(minHeight: 14),
            child: pw.Text(map.key,
                style: pw.TextStyle(
                    font: defFontMedium,
                    fontSize: 10,
                    color: PdfColor.fromInt(0xFF777777))),
          ),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: pw.EdgeInsets.only(left: 4, top: 4, right: 4, bottom: 4),
            constraints: pw.BoxConstraints(
                minHeight: useMaxSize[index] ? 50 : 20,
                maxHeight: useMaxSize[index] ? 50 : 20),
            decoration: pw.BoxDecoration(
                border: pw.Border(
                    left: pw.BorderSide(color: PdfColor.fromInt(0xFF777777)))),
            child: pw.Text(map.value ?? "",
                style: pw.TextStyle(
                    font: defFontReg, fontSize: 8, color: PdfColors.black)),
          ),
        )
      ]);
      return pw.Container(
          constraints: pw.BoxConstraints(minHeight: 14),
          decoration: pw.BoxDecoration(
              border: pw.Border(
            right: pw.BorderSide(color: PdfColor.fromInt(0xFF777777)),
            left: pw.BorderSide(color: PdfColor.fromInt(0xFF777777)),
            top: pw.BorderSide(color: PdfColor.fromInt(0xFF777777)),
            bottom: index == mp.length - 1
                ? pw.BorderSide(color: PdfColor.fromInt(0xFF777777))
                : pw.BorderSide.none,
          )),
          child: pwr);
    });
    fg.addAll(fgg);
    return fg;
  }
}
