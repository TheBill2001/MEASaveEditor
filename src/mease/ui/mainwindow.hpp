#ifndef MEASE_MAINWINDOW_HPP
#define MEASE_MAINWINDOW_HPP

#include <QMainWindow>

namespace MEASE
{
class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = nullptr);
};
} // namespace MEASE

#endif // MEASE_MAINWINDOW_HPP
