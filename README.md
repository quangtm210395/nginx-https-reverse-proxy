![Title][nginx-reverse-proxy]
# Tạo một Reverse Proxy Server chạy trên nền HTTPs với Nginx và Lets Encrypt.

## Đầu tiên, để khởi đầu cho section này thì chúng ta cần chuẩn bị:
  - Một server linux (tớ xài ubuntu chạy EC2 instance của AWS, cấu hình t2.micro, là free tier nên hoàn toàn miễn phí).
  - Một máy tính cá nhân có thể SSH vào server.
  - Một domain (có thể  register free domain trên dot.tk)

## Bước đầu tiên: chúng ta sẽ config domain
Tớ dùng freenom nên sẽ truy cập vào trang quản lí domain của freenom để tạo A record trỏ về public IP của server.

![Config domain trên my.freenom.com][freenom-config]

## Bước thứ 2: chúng ta sẽ cài đặt các thư viện cần thiết
Các package mà tớ sẽ cài đặt ở bước này bao gồm:
  - Nginx
  - Certbot
### Cài đặt Nginx:
```
  sudo apt update
  sudo aupt install nginx
```
Bạn cần phải ấn `ENTER` để đồng ý cài đặt nginx
### Cài đặt Certbot
Đầu tiên, cần add repository:
```
sudo add-apt-repository ppa:certbot/certbot
```
Sau đó cài đặt Certbot với apt
```
sudo apt install python-certbot-nginx
```
Vậy là chúng ta đã cài xong nginx và Certbot để cấu hình SSL cho nginx. Tuy nhiên vẫn cần phải config một chút với Nginx để verify domain.

## Bước 3: Cấu hình domain với nginx
Để Certbot có thể tự động cài đặt SSL thì server của bạn phải được  truy cập vào từ domain mà bạn đăng kí certificate.

Trong bài viết này mình sẽ tiến hành cấu hình SSL cho domain mới tạo trên freenom.com là hikariq.ml.

Đầu tiên ta cần tạo file hikariq.ml trong folder /etx/nginx/sites-available

<script src="https://gist.github.com/quangtm210395/a4ad15189136f71faa62c1ad94bbb8b4.js"></script>

[nginx-reverse-proxy]: https://hikariq-article-images.s3-ap-southeast-1.amazonaws.com/nginx-reverse-proxy.png
[freenom-config]: https://hikariq-article-images.s3-ap-southeast-1.amazonaws.com/freenomconfig.jpg