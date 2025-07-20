// SPDX-FileCopyrightText: 2025 Trần Nam Tuấn <tuantran1632001@gmail.com>
// SPDX-License-Identifier: GPL-3.0-only

#include "mease/ui/mainwindow.hpp"
#include <KAboutData>
#include <KIconTheme>
#include <KLocalizedString>

#include <QApplication>
#include <QCommandLineParser>

#ifdef Q_OS_WIN
#include <Windows.h>
#endif

using namespace Qt::Literals::StringLiterals;

int main(int argc, char **argv)
{
#ifdef Q_OS_WIN
    // If ran from a console, redirect the output there
    if (AttachConsole(ATTACH_PARENT_PROCESS)) {
        freopen("CONOUT$", "w", stdout);
        freopen("CONOUT$", "w", stderr);
    }
#endif

    KIconTheme::initTheme();

    QApplication application(argc, argv);

    KLocalizedString::setApplicationDomain("MEASE");

    KAboutData aboutData(u"MEASE"_s,
                         i18n("Mass Effect: Andromeda Save Editor"),
                         QStringLiteral("0.0.1"),
                         i18n("Mass Effect: Andromeda Save Editor"),
                         KAboutLicense::GPL_V3,
                         i18n("Copyright 2025, Trần Nam Tuấn <tuantran1632001@gmail.com>"));

    aboutData.addAuthor(i18n("Trần Nam Tuấn"), i18n("Author"), QStringLiteral("tuantran1632001@gmail.com"));
    aboutData.setOrganizationDomain("thebill2001.github.io");
    // aboutData.setDesktopFileName(QStringLiteral("org.example.testapp"));

    KAboutData::setApplicationData(aboutData);
    // application.setWindowIcon(QIcon::fromTheme(QStringLiteral("testapp")));

    QCommandLineParser parser;
    aboutData.setupCommandLine(&parser);

    parser.process(application);
    aboutData.processCommandLine(&parser);

    MEASE::MainWindow mainWindow;
    mainWindow.show();

    return application.exec();
}
