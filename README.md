# Purpose

This tool is aimed to make a simple invoice. Invoice is saved as PDF document.

# How to use

First of all you should prepare your invoice in TeX notation. This repo contains couple examples:
* [`src/example-invoice-fixed-dates.tex`](src/example-invoice-fixed-dates.tex) -- Fixed invoice and due dates are provided by the `\invoice` macro.
* [`src/example-invoice-monthly.tex`](src/example-invoice-monthly.tex) -- The `\invoiceMonthly` macro helps to create a monthly invoice.

The facsimile file is expected to be named as `facsimile.jpg` and placed in the invoice's directory by default. One may change the path to facsimile file by providing a custom value of the `\facsimileFile` macro.

The next step is making a PDF. One may build PDF inside the Docker container (described by [`make/docker/Dockerfile`](make/docker/Dockerfile)) or directly by a LaTeX installed in his host system.

## Make inside the Docker container

Requirements:
1. POSIX compatible environment with `bash`.
2. Docker v.23 or newer.

To make an invoice run [`make/docker/run-invoice`](make/docker/run-invoice) script:
```
./make/docker/run-invoice <path_to_your_invoice_tex> [-- <tex_macro_name>=<new_value>]
```

You are welcome to define simple TeX macros by command line arguments. For example it may be `\invoiceYear`, `\invoiceMonth`, `\dueTermsDays` or `\facsimileFile` macros defined in the [`src/example-invoice-monthly.tex`](src/example-invoice-monthly.tex) example.

## Make at the host system

Requirements:
1. Installed LaTeX system.
2. The [`src/simple-invoice.cls`](src/simple-invoice.cls) class file have to be available by LaTeX.

One may run the build script [`make/invoice`](make/invoice) if `bash` is available:
```
./make/invoice <path_to_your_invoice_tex> [-- <tex_macro_name>=<new_value>]
```

or make the TeX file in any other preferred way.
