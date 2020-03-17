# Tạo một Reverse Proxy Server chạy trên nền HTTPs với Nginx và Lets Encrypt.

## Đầu tiên, để khởi đầu cho section này thì chúng ta cần chuẩn bị:
  - Một server linux (mình xài ubuntu chạy EC2 instance của AWS, cấu hình t2.micro, là free tier nên hoàn toàn miễn phí).
  - Một máy tính cá nhân có thể SSH vào server.
  - Một domain (có thể  register free domain trên dot.tk)

## Bước đầu tiên: chúng ta sẽ config domain
Tớ dùng freenom nên sẽ truy cập vào trang quản lí domain của freenom để tạo A record trỏ về public IP của server.

![Config domain trên my.freenom.com][freenom-config]

[freenom-config]: https://hikariq-article-images.s3-ap-southeast-1.amazonaws.com/freenomconfig.jpg