%% Author:      Nikita Voronchev <n.voronchev@gmail.com>
%% Description: Simple invoice

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{simple-invoice}[2023/11/04 0.0.1 Simple invoice maker]

%

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}

%

\RequirePackage{xcolor}
\RequirePackage{tabularx}
\RequirePackage{colortbl}
\RequirePackage{graphicx}
\RequirePackage{siunitx} % \num
\RequirePackage{setspace} % \setstretch
\RequirePackage{xparse}
\RequirePackage{fp}
\RequirePackage[calc]{datetime2}

\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage[default]{lato}

\RequirePackage[
    top=2.5cm,
    bottom=2.25cm,
    left=2cm,
    right=2cm,
]{geometry}

\pagestyle{empty}

\setlength\parindent{0pt}

\setstretch{1.4}

\renewcommand{\arraystretch}{1.8}

\DTMnewdatestyle{myDateFormatWithoutYear}{%
    \renewcommand{\DTMdisplaydate}[4]{\DTMshortmonthname{##2} \DTMtwodigits{##3}}%
    \renewcommand{\DTMDisplaydate}{\DTMdisplaydate}}
\DTMnewdatestyle{myDateFormat}{%
    \renewcommand{\DTMdisplaydate}[4]{\DTMshortmonthname{##2} \DTMtwodigits{##3}, \number##1}%
    \renewcommand{\DTMDisplaydate}{\DTMdisplaydate}}
\DTMsetdatestyle{myDateFormat}

%
% Amount
%

\FPset{\totalAmountCounter}{0}

\NewDocumentCommand{\currencyText}{}{}
\NewDocumentCommand{\currency}{m}{
    \RenewDocumentCommand{\currencyText}{}{#1}
}

\NewDocumentCommand{\amountSeparatorText}{}{{,}}
\NewDocumentCommand{\amountSeparator}{m}{
    \RenewDocumentCommand{\amountSeparatorText}{}{#1}
}

\newcommand{\amount}[1]{
    \currencyText\num[
        mode = text,
        reset-text-family = false,
        reset-text-series = false,
        reset-text-shape = false,
        group-minimum-digits = 4,
        group-digits = integer,
        group-separator = {\amountSeparatorText},
        round-mode = places,
        round-precision = 2]{#1}
}

%
% Date commands
%



%
% Other commands
%

\newcount\dueDateRegister
\NewDocumentCommand\invoiceMonthly{mmmo}{
    \DTMsavedate{monthFirstDay}{#2-#3-1}
    \DTMsavedate{monthLastDay}{#2-#3-last}

    \NewDocumentCommand{\monthFirstDayText}{}{\DTMusedate{monthFirstDay}}
    \NewDocumentCommand{\monthLastDayText}{}{\DTMusedate{monthLastDay}}
    \NewDocumentCommand{\monthDaysRangeText}{}{%
        {\DTMsetdatestyle{myDateFormatWithoutYear}\DTMusedate{monthFirstDay}} - \monthLastDayText}

    \newcommand{\flagA}{false}
    \IfValueT{#4}{
        \ifstrempty{#4}{}{
            \ifdefmacro{#4}{
                \ifdefempty{#4}{}{\renewcommand{\flagA}{true}}
            }{
                \ifstrempty{#4}{}{\renewcommand{\flagA}{true}}
            }
        }
    }

    \newcommand{\dueDayText}{}
    \ifdefstring{\flagA}{true}{
        \DTMsaveddateoffsettojulianday{monthLastDay}{#4}{\dueDateRegister}
        \DTMsavejulianday{dueDate}{\dueDateRegister}
        \renewcommand{\dueDayText}{\DTMusedate{dueDate}}
    }{}

    \invoice{#1}{\monthLastDayText}[\dueDayText]
}

\NewDocumentCommand\invoice{mmo}{
    \NewDocumentCommand{\invoiceDateText}{}{#2}
    \NewDocumentCommand{\invoiceText}{}{
        {\large \bf \MakeUppercase{INVOICE}} \\
        #1

        \vspace{0.015\textheight}
        {\large \bf \MakeUppercase{DATE}} \\
        \invoiceDateText

        \IfValueT{#3}{
            \newcommand{\flagB}{false}
            \ifstrempty{#3}{}{
                \ifdefmacro{#3}{
                    \ifdefempty{#3}{}{\renewcommand{\flagB}{true}}
                }{
                    \ifstrempty{#3}{}{\renewcommand{\flagB}{true}}
                }
            }
            \ifdefstring{\flagB}{true}{
                \vspace{0.015\textheight}
                {\large \bf \MakeUppercase{DUE DATE}} \\
                #3
            }{}
        }
    }
}


\NewDocumentCommand\counterparty{mommoo}{
    % Name
    { \bf #1 }

    % Business number
    \vspace{0.015\textheight}
    {\bf {\IfValueTF{#2}{#2}{Business Number}}:} #3

    % Address
    \vspace{0.005\textheight}
    #4

    % Phone Number
    \IfValueT{#5}{
        \vspace{0.005\textheight}
        #5}

    % E-Mail
    \IfValueT{#6}{
        \vspace{0.005\textheight}
        #6}
}

\NewDocumentCommand\me{mommoo}{
    \NewDocumentCommand{\meText}{}{
        \counterparty{\huge \MakeUppercase{#1}}[#2]{#3}{#4}[#5][#6]
    }
}

\NewDocumentCommand\company{mommoo}{
    \NewDocumentCommand{\companyText}{}{
        \counterparty{\LARGE #1}[#2]{#3}{#4}[#5][#6]
    }
}

\newcolumntype{L}[1]{>{\hsize=#1\hsize\raggedright\arraybackslash}X}
\newcolumntype{R}[1]{>{\hsize=#1\hsize\raggedleft\arraybackslash}X}
\newcolumntype{C}[1]{>{\hsize=#1\hsize\centering\arraybackslash}X}

\NewDocumentCommand\taskList{m}{}
\NewDocumentCommand\task{momm}{
    \FPupn{\preRowAmountCounter}{#4 #3 *}
    \FPadd{\totalAmountCounter}{\totalAmountCounter}{\preRowAmountCounter}
    \expandafter\def\expandafter\taskList\expandafter{\taskList
        \\
        {\bf #1} & \amount{#3} & #4 & \amount{\FPprint{\preRowAmountCounter}} \\
        \vspace*{-1.9\baselineskip}
        #2 & & &
    }
}

\NewDocumentCommand\sign{mo}{
    \NewDocumentCommand{\signText}{}{
        \includegraphics{#1}

        {\bf DATE SIGNED} \\
        \IfValueTF{#2}{#2}{\invoiceDateText}
    }
}

\NewDocumentCommand\additional{m}{
    \NewDocumentCommand{\additionalText}{}{#1}
}

\NewDocumentCommand\placeInvoiceDocument{}
{
    \begin{document}
        \begin{minipage}[t][][t]{0.5\textwidth}
            \meText
        \end{minipage}
        \begin{minipage}[t][][t]{0.5\textwidth}
            \raggedleft

            \invoiceText

            \vspace{0.015\textheight}
            {\large \bf \MakeUppercase{BALANCE DUE}} \\
            \amount{\FPprint{\totalAmountCounter}}
        \end{minipage}

        \vspace{0.02\textheight}
        {\color{gray}\hrule}
        \vspace{0.02\textheight}

        \begin{minipage}[t][][t]{0.5\textwidth}
            { \large \MakeUppercase{BILL TO} }

            \vspace{0.010\textheight}

            \companyText
        \end{minipage}

        \vspace{0.03\textheight}

        \begin{tabularx}{\textwidth}{L{2.80} R{0.40} R{0.30} R{0.50}}
            \hline
            \bf DESCRIPTION & \bf RATE & \bf QTY & \bf AMOUNT \\
            \hline
            \taskList \\
            \arrayrulecolor{gray}\hline
        \end{tabularx}

        \hfill
        \begin{tabularx}{0.5\textwidth}{L{1} R{1}}
            \bf TOTAL & \amount{\FPprint{\totalAmountCounter}} \\
            \arrayrulecolor{gray}\hline
            \bf BALANCE DUE	USD & \bf \amount{\FPprint{\totalAmountCounter}} \\
            \arrayrulecolor{gray}\hline
        \end{tabularx}

        \vspace{0.03\textheight}

        \hfill
        \begin{minipage}{0.5\textwidth}
            \signText
        \end{minipage}

        \vspace{0.03\textheight}

        \additionalText
    \end{document}
}