# Tổng quát

* Mình tạo ra Github với nhu cầu để giảm tải băng thông khi sử dụng mạng internet nói chung và tiết kiệm dung lượng cho gói 3G/4G nói riêng. Github của mình tập trung chặn các quảng cáo tại Việt Nam.
* Một số ứng dụng lạm dụng việc chèn quảng cáo vào ứng dụng làm rối mắt người dùng, hoặc đặt quảng cáo tại những vị trí dễ nhấn nhầm nhằm tăng lượt nhấn vào quảng cáo, làm cho người sử dụng khó chịu khi chuyển trở về ứng dụng.
* Ngoài ra, việc chặn theo dõi cũng chặn các nhà quảng cáo thu thập dữ liệu, theo dõi hành vi người dùng.

# Địa chỉ

Trang Github: https://github.com/bigdargon/hostsVN

Báo lỗi: https://github.com/bigdargon/hostsVN/issues

Wiki hướng dẫn: https://github.com/bigdargon/hostsVN/wiki

# So sánh

Bảng dưới đây so sánh một số tính năng cơ bản dùng để chặn quảng cáo, mỗi ứng dụng có ưu và khuyết điểm khác nhau.  Tùy vào nhu cầu mỗi người mà chọn ứng dụng cho phù hợp. 

|   |[**Adblock**](https://github.com/bigdargon/hostsVN/wiki/Adblock)|[**Adguard Pro**](https://github.com/bigdargon/hostsVN/wiki/Adguard-Pro)|[**Shadowrocket**](https://github.com/bigdargon/hostsVN/wiki/Shadowrocket)|[**Surge**](https://github.com/bigdargon/hostsVN/wiki/Surge)|
|:-|:-:|:-:|:-:|:-:|
|Giá|45.000 VND|22.000 VND|69.000 VND|**Miễn phí**|
|Nâng cấp trong apps|**Không**|**Không**|**Không**|1.099.000 VND|
|VPN bật khi khởi động|**Có**|**Có**|Không|Không|
|Tự động cập nhật|Không|**Có**|Không|**Có**|
|Tải về|[Tại đây](https://itunes.apple.com/app/adblock/id691121579?mt=8)|[Tại đây](https://itunes.apple.com/app/apple-store/id1126386264?mt=8)|[Tại đây](https://itunes.apple.com/app/shadowrocket/id932747118?mt=8)|[Tại đây](https://itunes.apple.com/app/surge-3-web-developer-tool/id1329879957?mt=8)|

> Theo quan điểm cá nhân, mình cảm thấy `Surge` chặn quảng cáo ổn định và mạnh mẽ nhất, không cần nâng cấp bản `PRO` vẫn sử dụng được các tính năng cơ bản để chặn. Ứng dụng không tự động bật VPN sau mỗi lần mở hay khởi động lại thiết bị, nhưng chỉ cần vào ứng dụng bật VPN lại là sử dụng xuyên suốt mà VPN không bị ngắt hoặc bạn có thể thêm widget để bật nhanh hơn từ màn hình chính.

# Câu hỏi thường gặp

## Tôi phải sử dụng ứng dụng nào để chặn tên miền quảng cáo?

Bạn có thể sử dụng một số ứng dụng và tham khảo hướng dẫn sử dụng dưới đây

* Adblock của FutureMind - [Hướng dẫn cài đặt](https://github.com/bigdargon/hostsVN/wiki/Adblock)
* Adguard Pro - [Hướng dẫn cài đặt](https://github.com/bigdargon/hostsVN/wiki/Adguard-Pro)
* Shadowrocket - [Hướng dẫn cài đặt](https://github.com/bigdargon/hostsVN/wiki/Shadowrocket)
* Surge - [Hướng dẫn cài đặt](https://github.com/bigdargon/hostsVN/wiki/Surge)

## Trong quá trình sử dụng, danh sách chặn gây lỗi trong một số ứng dụng. Vậy tôi phải làm gì?

Bạn chỉ cần làm theo hướng dẫn báo lỗi để chụp màn hình lỗi chi tiết và gửi báo lỗi [tại đây](https://github.com/bigdargon/hostsVN/issues)

* Adblock của FutureMind - [Hướng dẫn báo lỗi](https://github.com/bigdargon/hostsVN/wiki/Adblock#b%C3%A1o-l%E1%BB%97i)
* Adguard Pro - [Hướng dẫn báo lỗi](https://github.com/bigdargon/hostsVN/wiki/Adguard-Pro#b%C3%A1o-l%E1%BB%97i)
* Shadowrocket - [Hướng dẫn báo lỗi](https://github.com/bigdargon/hostsVN/wiki/Shadowrocket#b%C3%A1o-l%E1%BB%97i)
* Surge - [Hướng dẫn báo lỗi](https://github.com/bigdargon/hostsVN/wiki/Surge#b%C3%A1o-l%E1%BB%97i)

## Tại sao tôi đã sử dụng chặn quảng cáo nhưng vẫn thấy một số quảng cáo ở ứng dụng Facebook, Youtube...?

Việc chặn quảng cáo chỉ áp dụng theo tên miền hoặc chặn trên giao thức `http`, các ứng dụng Facebook hay Youtube sử dụng giao thức `https`, những ứng dụng bên thứ 3 chặn quảng cáo bằng VPN không thể phân giải được tên miền đã mã hóa. Mình khuyên bạn sử dụng các ứng dụng tùy chỉnh như `Facebook++` `Youtube++` hay `Youtube Cercube` để chặn hoàn toàn quảng cáo.

## Tại sao tôi vẫn nhìn thấy quảng cáo của Facebook ở các ứng dụng khác?

Như đã giải thích ở trên, `Faceook` sử dụng giao thức `https` mã hóa và mặt khác `Facebook` đặt quảng cáo, đăng nhập, phân tích... vào tên miền `graph.facebook.com`. Nếu bạn không sử dụng các ứng dụng của `Facebook` bạn hãy thêm tên miền `graph.facebook.com` vào danh sách chặn, lý do nếu chặn tên miền này các ứng dụng của `Facebook` sẽ không hoạt động.

## Tập tin `hosts` là gì?

Trong các hệ điều hành Windows, Linux, Mac, File Hosts được lưu trữ thông tin IP của các máy chủ và tên miền tại máy tính mỗi người. Hiểu đơn giản là bạn có thể điều hướng tên miền sang 1 IP nào khác hoặc chặn truy cập. Mặc định nội dung trong file hosts chỉ là những gợi ý, chú thích. Bạn có thể thêm mới không giới hạn Ip, tên miền phục vụ cho mục đích của mình.

Ví dụ:

```
#[google]
0.0.0.0 doubleclick.net
0.0.0.0 g.doubleclick.net
0.0.0.0 stats.g.doubleclick.net
0.0.0.0 googleads.g.doubleclick.net
# etc...
```

## Vị trí tập tin `hosts` nằm ở đâu?

Mac OS X, iOS, Android, Linux: `/etc/hosts`

Winodws: `%SystemRoot%\system32\drivers\etc\hosts`

## Tôi thấy tập tin `hosts` ở một số trang sử dụng địa chỉ `127.0.0.1` để chặn quảng cáo, nhưng ở đây lại sử dụng địa chỉ `0.0.0.0` để chặn?

Sau nhiều lần thử và tham khảo từ nhiều nguồn nước ngoài, mình nhận thấy một số thiết bị sử dụng địa chỉ `127.0.0.1` làm địa chỉ cục bộ, khi sử dụng địa chỉ này để chặn sẽ tạo vòng lặp dẫn đến việc chậm trong việc truy cập. Khi sử dụng địa chỉ `0.0.0.0` các truy vấn sẽ trả về ngay lập tức mà không bị lặp, nên thời gian truy cập sẽ nhanh hơn.
