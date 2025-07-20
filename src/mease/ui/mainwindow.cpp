#include "mease/ui/mainwindow.hpp"

#include <QApplication>
#include <QLabel>
#include <QStyleHints>

using namespace Qt::StringLiterals;

namespace MEASE
{
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow{parent}
{
    auto *label = new QLabel(this);
    label->setPixmap(QIcon::fromTheme(u"actor"_s).pixmap(50, 50));

    connect(qApp->styleHints(), &QStyleHints::colorSchemeChanged, label, [label]() {
        label->setPixmap(QIcon::fromTheme(u"actor"_s).pixmap(50, 50));
    });
}
} // namespace MEASE