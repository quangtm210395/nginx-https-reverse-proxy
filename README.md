![Title][nginx-reverse-proxy]
# Tạo một Reverse Proxy Server chạy trên nền HTTPs với Nginx và Lets Encrypt.

## Đầu tiên, để khởi đầu cho section này thì chúng ta cần chuẩn bị:
  - Một server linux (tớ xài ubuntu chạy EC2 instance của AWS, cấu hình t2.micro, là free tier nên hoàn toàn miễn phí).
  - Một máy tính cá nhân có thể SSH vào server.
  - Một domain (có thể  register free domain trên dot.tk)

## Bước đầu tiên: chúng ta sẽ config domain
Tớ dùng freenom nên sẽ truy cập vào trang quản lí domain của freenom để tạo A record trỏ về public IP của server.

![Config domain trên my.freenom.com][freenom-config]

## Bước 2: chúng ta sẽ cài đặt các thư viện cần thiết
Các package mà tớ sẽ cài đặt ở bước này bao gồm:
  - Nginx
  - Certbot
### Cài đặt Nginx:
```
  sudo apt update
  sudo apt install nginx
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

Sau đó ta cần tạo alias file này sang thư mục /etc/nginx/sites-enabled/
```
sudo ln -s /etc/nginx/sites-available/hikariq.ml etc/nginx/sites-enabled/
```
Tiếp theo ta thực hiện validate syntax của file config cho domain hikariq.ml:
```
sudo nginx -t
```
```
output
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
Nếu có thông báo như trên có nghĩa là chỉnh sửa của chúng ta không có lỗi gì, vậy thì tiến hành reload nginx thôi:
```
sudo systemctl reload nginx
```
Giờ thì Certbot có thể tìm thấy server của chúng ta để validate rồi.

## Bước 4: Đảm bảo là chúng ta đã mở firewall để cho access vào HTTPs ở server.
Ở bước này thì chúng ta sẽ dùng `ufw` để cài đặt firewall
```
sudo ufw status
```
![Ufw status][ufw-status]
Nếu kết quả hiện như trên thì ufw đã được cấu hình để allow Nginx Http và Https. Nếu chưa thì thực hiện gõ lệnh sau:
```
sudo ufw allow 'Nginx Full'
```
Vậy là việc cấu hình firewall đã xong.
Tiếp theo, chúng ta sẽ chạy Certbot để  tạo ra certificate.

## Bước 5: Lụm một cái SSL Certificate thui.
Chúng ta sẽ run Certbot với plugin nginx:
```
sudo certbot --nginx -d hikariq.ml -d www.hikariq.ml
```
Nhớ thay domain của các bạn vào nhé.
Nếu lệnh này chạy success thì các bạn sẽ nhận được một câu hỏi như này: 
```
Output:
Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
-------------------------------------------------------------------------------
1: No redirect - Make no further changes to the webserver configuration.
2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
new sites, or if you're confident your site works on HTTPS. You can undo this
change by editing your web server's configuration.
-------------------------------------------------------------------------------
Select the appropriate number [1-2] then [enter] (press 'c' to cancel):
```
Bạn chỉ việc gõ 1 hoặc 2 để chọn câu trả lời và ấn `ENTER`.

Trong đó 1 là không redirect, 2 là Redirect tất cả những request không phải là HTTPS vào HTTPS (Certbot sẽ edit config nginx của bạn để làm việc này thay bạn).

Sau khi bạn ấn `ENTER` thì sẽ có thông báo tương tự như sau:
```
Output
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/hikariq.ml/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/hikariq.ml/privkey.pem
   Your cert will expire on 2020-05-01. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option. To non-interactively renew *all* of
   your certificates, run "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

Như vậy là certificate của bạn đã được download, cài đặt và cấu hình vào nginx. Thử reload lại trang web trên domain của bạn để kiểm tra lại kết quả nhé, trang web sẽ tự động redirect về https:// một cách thần kì.

## Bước 6: Kiểm tra lại cấu hình tự động gia hạn của certbot
Certificate tạo bở Let's Encrypt chỉ valid trong vòng 90 ngày. Bởi vậy để sử dụng được certificate này lâu thì bạn cần phải tự động gia hạn khi sắp hết hạn. Certbot sẽ giúp bạn làm việc này chỉ với 1 câu lệnh:
```
sudo certbot renew --dry-run
```
Nếu kết quả của câu lệnh này không có lỗi thì coi như bạn đã thành công. Certbot sẽ  tạo ra 1 renew script trong folder /etc/cron.d và run nó khi có bất kì certificate nào sắp hết hạn (còn trong 30 ngày).

## Bước 7: cấu hình reverse proxy cho nginx
Ở bước này chúng ta sẽ tiến hành cấu hình proxy_pass trong nginx để đưa request từ bên ngoài đến với server mà ta mong muốn (có thể là 1 server khác hoặc localhost bên trong server này)

Giả sử chúng ta có 1 nodejs server chạy ở cổng 3000, và muốn forward tất cả request đến domain với path là `/proxy` đến với server này.

Chúng ta chỉ cần đơn giản thêm đoạn code sau vào file /etc/nginx/sites-available/hikariq.ml
```
location /proxy/ {
  proxy_pass                                      http://127.0.0.1:3000/;
  proxy_http_version                              1.1;
  proxy_cache_bypass                              $http_upgrade;

  proxy_set_header Upgrade                        $http_upgrade;
  proxy_set_header Connection                     "upgrade";
  proxy_set_header Host                           $host;
  proxy_set_header X-Real-IP                      $remote_addr;
  proxy_set_header X-Forwarded-For                $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto              $scheme;
  proxy_set_header X-Forwarded-Host               $host;
  proxy_set_header X-Forwarded-Port               $server_port;
}
```
![Adding proxy to 3000][nginx-adding-proxy]
Save file và quit thôi. Vậy là chúng ta đã cấu hình xong proxy.

Chạy lệnh `sudo nginx -t` để kiểm tra syntax và `sudo systemctl reload nginx` để reload lại server.

Cuối cùng thì chỉ cần truy cập vào domain với path /proxy để xem kết quả.

Trong bài viết này mình đã đề cập đến cách để tạo 1 reverse proxy server over HTTPS với nginx và Let's Encrypt, tuy nhiên chưa nói với các bạn làm sao để kiếm một con server free để nghịch như thế này. Bài viết tới mình sẽ chia sẻ cho các bạn cách để tận dụng  Free Tier (tài nguyên miễn phí) ở các Cloud Provider như AWS hay Google Cloud nhé. Cám ơn các bạn.


[nginx-reverse-proxy]: https://hikariq-article-images.s3-ap-southeast-1.amazonaws.com/nginx-reverse-proxy.png
[freenom-config]: https://hikariq-article-images.s3-ap-southeast-1.amazonaws.com/freenomconfig.jpg
[ufw-status]: https://hikariq-article-images.s3-ap-southeast-1.amazonaws.com/ufw-status.png
[nginx-adding-proxy]: https://hikariq-article-images.s3-ap-southeast-1.amazonaws.com/nginx-adding-proxy.png