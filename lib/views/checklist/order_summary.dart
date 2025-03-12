import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/controllers/app_controller.dart';
import 'package:inventory/repo/app_repo.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/tools/enums.dart';
import 'package:inventory/tools/extensions.dart';
import 'package:inventory/views/auth/auth_page.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:inventory/views/explorer/explorer.dart';
import 'package:inventory/views/shared.dart';
import 'package:printing/printing.dart';
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
  final frameId = "archpage";
  bool isSaving = false;
  Rx<Invoice> invoice = Invoice(productsUsed: [], servicesUsed: []).obs;
  final ltec = TextEditingController(
      text: "7000",
    );

  @override
  void initState() {
    // TODO: implement initState
    invoice.value.orderId = widget.order.id;
    if (widget.order.id != 0) {
      final fg = Get.find<AppController>()
          .allInvoices
          .where((test) => test.orderId == widget.order.id);
      if (fg.isNotEmpty) {
        invoice.value = fg.first;
      }
      ltec.text = invoice.value.labourCost.toString();
    }
    print(ltec.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // padding: EdgeInsets.all(24),
        child: Builder(builder: (context) {
          final title = widget.order.isDispatched
              ? "Dispatch Order Summary"
              : "Service Order Summary";
          final toreturn = Column(
            children: [
              Ui.boxWidth(24),
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
                  if (widget.order.id == 0) Ui.boxWidth(16),
                  if (widget.order.id == 0)
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
                          widget.order.createdAt ?? DateTime.now(),
                          order: widget.order,
                          orderFinished: widget.order.dispatchedAt,
                          invoice: widget.order.isDispatched ? invoice.value : null,
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
                      titleValueText(
                          "Full Name", widget.order.customerDetails?.fullName),
                      titleValueText(
                          "Email", widget.order.customerDetails?.email),
                      titleValueText(
                          "Phone Number", widget.order.customerDetails?.phone),
                      titleValueText("Customer Type",
                          widget.order.customerDetails?.customerType),
                    ],
                  )),
              imageContainer(true),
              serviceItem(
                  "VEHICLE",
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleValueText("Make", widget.order.customerCar?.make),
                      titleValueText("Model", widget.order.customerCar?.model),
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
                  "VEHICLE CONDITION",
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleValueText("Mileage At Reception",
                          widget.order.mileageOnReception.toString()),
                      titleValueText(
                          "Fuel Level At Reception", widget.order.fuelLevel),
                      titleValueText("Visible Damage ", widget.order.bodyCheck),
                      titleValueText(
                          "Additonal Observations", widget.order.observations),
                    ],
                  )),
              imageContainer(false),

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
                                  widget.order.conditions[value[index].rawId] ==
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
              if (widget.order.id == 0)
                SizedBox(
                  width: wideUi(context),
                  child: AppButton(
                    onPressed: () {
                      Get.dialog(AppDialog.normal("Submit Service Order",
                          "Are youy sure you want to submit this service order ?, NB: this will send an email to the customer if any email was provided.",
                          titleA: "Yes", titleB: "No", onPressedA: () async {
                        final f = await Get.find<AppController>()
                            .submitServiceOrder();
                        if (f) {
                          Get.offAll(ChoosePage());
                        }
                      }, onPressedB: () {
                        Get.back();
                      }));
                    },
                    text: "Submit",
                  ),
                ),
              if (widget.order.id != 0) InvoiceList(invoice,ltec),
              if (widget.order.id != 0 && !widget.order.isDispatched)
                SizedBox(
                  width: wideUi(context),
                  child: AppButton(
                    onPressed: () {
                      invoice.value.orderId = widget.order.id;
                      invoice.value.totalCost = invoice.value.rawTotalCost;
                      if (invoice.value.validate()) {
                        Get.dialog(AppDialog.normal("Dispatch Order",
                            "Are youy sure you want to dispatch this service order ?, NB: this will send an email to the customer if any email was provided.",
                            titleA: "Yes", titleB: "No", onPressedA: () async {
                          final f = await Get.find<AppController>()
                              .dispatchOrder(widget.order, invoice.value);
                          if (f) {
                            Get.offAll(ChoosePage());
                          }
                        }, onPressedB: () {
                          Get.back();
                        }));
                      } else {
                        Ui.showError(
                            "Please check the Services/Products Section, None values are not acceptable");
                      }
                    },
                    text: "Dispatch",
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
              child: Stack(
                children: [
                  Container(
                    color: AppColors.white.withOpacity(0.7),
                    width: Ui.width(context),
                    height: Ui.height(context),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: min(1200, Ui.width(context) - 48)),
                          child: toreturn),
                    ],
                  ),
                  if (widget.order.id != 0)
                    Positioned(
                        top: 24,
                        left: 8,
                        child: SafeArea(
                          child: BackButton(
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        )),
                ],
              ),
            ),
          );
          // }
          // return toreturn;
        }),
      ),
    );
  }

  imageContainer(bool g) {
    String img = "";
    final controller = Get.find<AppController>();
    if (g) {
      img = (widget.order.id == 0
              ? controller.customerImagePath.value
              : widget.order.customerImage) ??
          "";
    } else {
      img = (widget.order.id == 0
              ? controller.mileageImagePath.value
              : widget.order.mileageImage) ??
          "";
    }
    if (img.isEmpty) return SizedBox();
    return Column(children: [
      Builder(builder: (context) {
        return SizedBox(
          width: wideUi(context),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0, bottom: 8),
                child: AppText.thin(
                    g ? "Image of Customer/Driver" : "Vehicle Dashboard Image"),
              )),
        );
      }),
      ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: wideUi(context),
            maxWidth: wideUi(context),
            minHeight: 128),
        child: CurvedContainer(
          border: Border.all(color: AppColors.grey),
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: widget.order.id == 0
              ? Image.file(
                  File(img),
                  fit: BoxFit.cover,
                )
              : Transform.rotate(
                  angle: pi / 2,
                  child: Image.network(
                    "${AppUrls.baseURL}${AppUrls.upload}/all/$img",
                    fit: BoxFit.contain,
                  ),
                ),
        ),
      ),
      Ui.boxHeight(24),
    ]);
  }

  serviceItem(String title, Widget item) {
    return CurvedContainer(
      radius: 16,
      padding: EdgeInsets.only(left: 24),
      margin: EdgeInsets.only(bottom: 24),
      color: AppColors.primaryColor.withOpacity(0.2),
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
      {this.orderFinished,
      required this.order,
      this.invoice,
      this.sigUint,
      super.key});
  final DateTime orderDate;
  final DateTime? orderFinished;
  final String title;
  final Order order;
  final Invoice? invoice;
  final Uint8List? sigUint;

  @override
  State<CustomOrderPDFPage> createState() => _CustomOrderPDFPageState();
}

class _CustomOrderPDFPageState extends State<CustomOrderPDFPage> {
  late pw.Font defFontReg, defFontMedium, defFontBold, segoe;
  late pw.ImageProvider logo, bg;
  pw.ImageProvider? sig, ssig;
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
      sig = await networkImage(
          "${AppUrls.baseURL}${AppUrls.upload}/all/${widget.order.customerDetails!.signature}");
    }
    print(widget.order.serviceAdvisorDetails?.signature);
    if (widget.order.serviceAdvisorDetails?.signature.isNotEmpty ?? false) {
      ssig = await networkImage(
          "${AppUrls.baseURL}${AppUrls.upload}/all/${widget.order.serviceAdvisorDetails!.signature}");
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
    //summary
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
                            "Generated On : ${DateFormat("dd/MM/yyyy hh:mm:aa").format(DateTime.now())}",
                            style: pw.TextStyle(
                              font: defFontMedium,
                              fontSize: 8,
                            )),
                        pw.SizedBox(height: 4),
                        pw.Text(
                            "Order Created On : ${DateFormat("dd/MM/yyyy hh:mm:aa").format(widget.orderDate)}",
                            style: pw.TextStyle(
                              font: defFontMedium,
                              fontSize: 8,
                            )),
                        pw.SizedBox(height: 4),
                        if (widget.orderFinished != null)
                          pw.Text(
                              "Order Finished On : ${DateFormat("dd/MM/yyyy hh:mm:aa").format(widget.orderFinished!)}",
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
          ...descText("Vehicle Conditions", {
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
              pw.Container(
                  height: PdfPageFormat.a4.height,
                  width: PdfPageFormat.a4.width,
                  color: PdfColor.fromInt(0x88FFFFFF)),
              pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: pf)
            ]);
      },
    ));

    //invoice
    if (widget.invoice != null) {
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        build: (context) {
          Map<String, String> productUsed = {};
          Map<String, String> serviceUsed = {};
          final ap = Get.find<AppController>().allProducts;
          final sp = Get.find<AppController>().allBillyServices;
          for (var element in widget.invoice!.productsUsed) {
            final app = ap.where((test) => test.id == element.id).first;
            productUsed[
                    "${app.name} - ${element.qty} - ${element.unitPrice.toCurrency()}"] =
                element.totalPrice.toCurrency();
          }
          for (var element in widget.invoice!.servicesUsed) {
            serviceUsed[sp.where((test) => test.id == element.id).first.name] =
                element.totalPrice.toCurrency();
          }
          final pf = pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // HEADER
                pw.Row(children: [
                  pw.Expanded(child: pw.SizedBox()),
                  pw.Expanded(
                      child: pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                        pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Image(logo, width: 72, height: 72),
                        ),
                        pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text("MRS COCO Station, Alapere,Lagos",
                              style: pw.TextStyle(
                                font: defFontReg,
                                fontSize: 8,
                              )),
                        ),
                        pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text("Bill/Cash Receipt",
                              style: pw.TextStyle(
                                font: defFontBold,
                                fontSize: 16,
                              )),
                        ),
                      ])),
                  pw.Expanded(child: pw.SizedBox()),
                ]),

                // Labour Charge
                ...descText("Labour", {
                  "Charge": widget.invoice!.labourCost.toCurrency(),
                }),

                // Products Charge
                ...descText(
                  "Products Used",
                  productUsed,
                ),

                // Products Charge
                ...descText(
                  "Services",
                  serviceUsed,
                ),

                // Total Charge
                ...descText("TOTAL", {
                  "Grand Total": widget.invoice!.totalCost.toCurrency(),
                  "In Words": amountToWords(widget.invoice!.totalCost)
                }),

                // SERVICE
                pw.SizedBox(height: 16),
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
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
                                    child: sig == null
                                        ? pw.SizedBox()
                                        : pw.Image(sig!))),
                            pw.SizedBox(height: 8),
                            pw.Text("Customer Name:  ${widget.order.customer}",
                                style: pw.TextStyle(
                                    font: defFontReg,
                                    fontSize: 8,
                                    color: PdfColor.fromInt(0xFF1E1E1E))),
                          ]),
                      pw.Spacer(),
                      pw.Column(
                          mainAxisSize: pw.MainAxisSize.min,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            titleText("Attendant Signature",
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
                                    child: ssig == null
                                        ? pw.SizedBox()
                                        : pw.Image(ssig!))),
                            pw.SizedBox(height: 8),
                            pw.Text(
                                "Attendant Name:  ${widget.order.serviceAdvisor}",
                                style: pw.TextStyle(
                                    font: defFontReg,
                                    fontSize: 8,
                                    color: PdfColor.fromInt(0xFF1E1E1E))),
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
                pw.Container(
                    height: PdfPageFormat.a4.height,
                    width: PdfPageFormat.a4.width,
                    color: PdfColor.fromInt(0x88FFFFFF)),
                pw.Padding(
                    padding:
                        pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: pf)
              ]);
        },
      ));
    }

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

class InvoiceList extends StatelessWidget {
  const InvoiceList(this.invoice,this.ltec, {this.isOwn = true, super.key});
  final Rx<Invoice> invoice;
  final bool isOwn;
  final TextEditingController ltec;

  @override
  Widget build(BuildContext context) {
    // invoice.value.labourCost = double.tryParse(ltec.text) ?? 0;
    ltec.addListener(() {
      invoice.value.labourCost = double.tryParse(ltec.text) ?? 0;
      invoice.refresh();
    });
    return Column(
      children: [
        if (isOwn)
          AppText.bold("BILL/CASH RECEIPT",
              fontSize: 24, fontFamily: Assets.appFontFamily2),
        if (isOwn) Ui.boxHeight(24),
        InvoiceItemWidget(
            title: "Labour Charge",
            isEnabled: invoice.value.id == 0 || !isOwn,
            labourTec: ltec),
        Ui.boxHeight(32),
        //Products
        AppDivider(),
        Ui.align(child: AppText.bold("Products")),
        Ui.boxHeight(8),
        Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: invoice.value.productsUsed
                .map((e) => InvoiceItemWidget(
                      item: e,
                      isProduct: true,
                      isEnabled: invoice.value.id == 0 || !isOwn,
                      titles: Get.find<AppController>()
                          .filterOptions["productId2"]!
                          .titles,
                      values: Get.find<AppController>()
                          .filterOptions["productId2"]!
                          .values as List<int>,
                    ))
                .toList(),
          );
        }),
        if (invoice.value.id == 0 || !isOwn)
          InvoiceItemCounter(() {
            invoice.value.productsUsed.add(InvoiceItem());
            invoice.refresh();
          }, () {
            if (invoice.value.productsUsed.isNotEmpty) {
              invoice.value.productsUsed.removeLast();
            }
            invoice.refresh();
          }),

        Ui.boxHeight(24),
        //Services
        AppDivider(),
        Ui.align(child: AppText.bold("Services")),
        Ui.boxHeight(8),
        Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: invoice.value.servicesUsed
                .map((e) => InvoiceItemWidget(
                      item: e,
                      isEnabled: invoice.value.id == 0 || !isOwn,
                      titles: Get.find<AppController>()
                          .filterOptions["billyServiceId"]!
                          .titles,
                      values: Get.find<AppController>()
                          .filterOptions["billyServiceId"]!
                          .values as List<int>,
                    ))
                .toList(),
          );
        }),
        if (invoice.value.id == 0 || !isOwn)
          InvoiceItemCounter(() {
            invoice.value.servicesUsed.add(InvoiceItem());
            invoice.refresh();
          }, () {
            if (invoice.value.servicesUsed.isNotEmpty) {
              invoice.value.servicesUsed.removeLast();
            }
            invoice.refresh();
          }),
        Ui.boxHeight(48),

        AppDivider(),
        Obx(() {
          return InvoiceItemWidget(
              title: "TOTAL CHARGES",
              isEnabled: false,
              labourTec: TextEditingController(
                text: invoice.value.rawTotalCost.toCurrency(),
              ));
        }),
        Ui.boxHeight(48),
      ],
    );
  }
}

class InvoiceItemCounter extends StatelessWidget {
  const InvoiceItemCounter(this.onAdd, this.onRemove, {super.key});
  final VoidCallback onAdd, onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              Icons.add_circle_outline,
              color: AppColors.primaryColor,
              onTap: onAdd,
            ),
            Ui.boxWidth(24),
            AppIcon(
              Icons.remove_circle_outline,
              color: AppColors.primaryColor,
              onTap: onRemove,
            )
          ],
        ),
      ),
    );
  }
}

class InvoiceItemWidget extends StatelessWidget {
  const InvoiceItemWidget(
      {this.item,
      this.title = "",
      this.titles = const [],
      this.values = const [],
      this.isEnabled = true,
      this.isProduct = false,
      this.labourTec,
      super.key});
  final List<String> titles;
  final List<int> values;
  final InvoiceItem? item;
  final bool isEnabled, isProduct;
  final String title;
  final TextEditingController? labourTec;

  @override
  Widget build(BuildContext context) {
    final qtyTec = TextEditingController();
    final upTec = TextEditingController();
    if (item != null) {
      qtyTec.text = item!.rawQty.value.toString();
      upTec.text = item!.rawUnitPrice.value.toString();
    }
    return SizedBox(
      width: Ui.width(context),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (item == null) Expanded(flex: 4, child: AppText.bold(title)),
        if (item == null)
          Expanded(
              flex: 1,
              child: CustomTextField(
                "",
                labourTec!,
                hasBottomPadding: false,
                varl: FPL.number,
                readOnly: !isEnabled,
                textAlign: TextAlign.right,
              )),
        if (item != null)
          Expanded(
              flex: 2,
              child: CustomTextField.dropdown(
                  titles, values, TextEditingController(), "",
                  isEnabled: isEnabled,
                  initOption: item!.rawId.value, onChanged: (p0) {
                item!.rawId.value = p0;
                if (p0 != 0) {
                  try {
                    if (isProduct) {
                      item!.rawUnitPrice.value = Get.find<AppController>()
                          .allProductsCurrentPrice
                          .where((test) => test.productId == p0)
                          .first
                          .cost;
                    } else {
                      item!.rawUnitPrice.value = Get.find<AppController>()
                          .allBillyServices
                          .where((test) => test.id == p0)
                          .first
                          .cost;
                    }

                    upTec.text = item!.rawUnitPrice.value.toString();
                  } catch (e) {
                    // TODO
                  }
                }
              })),
        if (item != null && isProduct)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Obx(() {
                return TextField(
                    controller: qtyTec,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    readOnly: !isEnabled,
                    enabled: item!.rawId.value > 0,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(hintText: "Qty"),
                    onChanged: (_) {
                      final maxQty = (Get.find<AppController>().allStockBalances.where((test) => test.productId == item!.rawId.value).firstOrNull?.quantity ?? 0);
                      item!.rawQty.value =
                          int.tryParse(qtyTec.text) ?? item!.qty;
                          if(item!.rawQty.value > maxQty){
                            item!.rawQty.value = maxQty;
                            qtyTec.text = maxQty.toString();
                            Ui.showError("Qty exceeds available in store");
                          }
                    });
              }),
            ),
          ),
        if (item != null)
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Obx(() {
                  return TextField(
                      controller: upTec,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      readOnly: !isEnabled,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(hintText: "Unit Price"),
                      enabled: item!.rawId.value > 0,
                      onChanged: (_) {
                        item!.rawUnitPrice.value =
                            double.tryParse(upTec.text) ?? item!.unitPrice;
                      });
                }),
              )),
        if (item != null)
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Obx(() {
                  return AppText.thin(item!.totalPrice.toCurrency(),
                      fontSize: 16, alignment: TextAlign.right);
                }),
              )),
      ]),
    );
  }
}

String numberToWords(int number) {
  // Handle zero as a special case
  if (number == 0) {
    return 'Zero';
  }

  // Handle negative numbers
  if (number < 0) {
    return 'Negative ${numberToWords(number.abs())}';
  }

  // Define word lists
  final List<String> ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  ];

  final List<String> tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  ];

  final List<String> scales = ['', 'Thousand', 'Million', 'Billion'];

  // Function to convert three-digit groups
  String convertLessThanOneThousand(int n) {
    if (n == 0) {
      return '';
    }

    String result = '';

    if (n >= 100) {
      result += '${ones[n ~/ 100]} Hundred';
      if (n % 100 != 0) {
        result += ' ';
      }
    }

    n %= 100;
    if (n > 0) {
      if (n < 20) {
        result += ones[n];
      } else {
        result += tens[n ~/ 10];
        if (n % 10 != 0) {
          result += '-${ones[n % 10].toLowerCase()}';
        }
      }
    }

    return result;
  }

  // Check if number is within range
  if (number > 999999999999) {
    return 'Number too large (exceeds 12 digits)';
  }

  String result = '';
  int scaleIndex = 0;

  while (number > 0) {
    int n = number % 1000;
    if (n != 0) {
      String groupText = convertLessThanOneThousand(n);
      if (scaleIndex > 0 && groupText.isNotEmpty) {
        result =
            '$groupText ${scales[scaleIndex]}${result.isEmpty ? '' : ' $result'}';
      } else {
        result = groupText + (result.isEmpty ? '' : ' $result');
      }
    }
    number ~/= 1000;
    scaleIndex++;
  }

  return result;
}

// Extended function that supports decimal places
String amountToWords(double amount,
    {String currency = 'Naira', String subCurrency = 'Kobo'}) {
  // Extract the integer and decimal parts
  int integerPart = amount.floor();
  int decimalPart = ((amount - integerPart) * 100).round();

  String result = numberToWords(integerPart);

  // Add currency
  if (integerPart == 1) {
    result += ' $currency';
  } else {
    result += ' $currency';
  }

  // Add decimal part if it exists
  if (decimalPart > 0) {
    result += ' and ${numberToWords(decimalPart)}';

    // Add sub-currency
    if (decimalPart == 1) {
      result += ' $subCurrency';
    } else {
      result += ' ${subCurrency}s';
    }
  }

  return result;
}
