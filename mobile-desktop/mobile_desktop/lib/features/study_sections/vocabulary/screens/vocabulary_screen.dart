import 'package:flutter/material.dart';
import 'topic_vocabulary_screen.dart';
import 'vocabulary_detail_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  // ===== Colors =====
  static const bgColor = Color(0xFF0F172A);
  static const cardColor = Color(0xFF141E30);
  static const primaryBlue = Color(0xFF3B82F6);
  static const borderBlue = Color(0xFF60A5FA);

  late TabController _tabController;
  final Map<String, List<Map<String, dynamic>>> topicVocabularyData = {
    'Colors': [
      {'word': 'red', 'vi': 'màu đỏ', 'phonetic': '/red/', 'pos': 'noun', 'meaning': 'the color of blood', 'meaning_vi': 'màu của máu'},
      {'word': 'blue', 'vi': 'màu xanh dương', 'phonetic': '/bluː/', 'pos': 'noun', 'meaning': 'the color of the sky', 'meaning_vi': 'màu của bầu trời'},
      {'word': 'green', 'vi': 'màu xanh lá', 'phonetic': '/ɡriːn/', 'pos': 'noun', 'meaning': 'the color of grass', 'meaning_vi': 'màu của cỏ'},
      {'word': 'yellow', 'vi': 'màu vàng', 'phonetic': '/ˈjeləʊ/', 'pos': 'noun', 'meaning': 'the color of the sun', 'meaning_vi': 'màu của mặt trời'},
      {'word': 'black', 'vi': 'màu đen', 'phonetic': '/blæk/', 'pos': 'noun', 'meaning': 'the darkest color', 'meaning_vi': 'màu tối nhất'},
      {'word': 'white', 'vi': 'màu trắng', 'phonetic': '/waɪt/', 'pos': 'noun', 'meaning': 'the color of snow', 'meaning_vi': 'màu của tuyết'},
      {'word': 'pink', 'vi': 'màu hồng', 'phonetic': '/pɪŋk/', 'pos': 'noun', 'meaning': 'a pale red color', 'meaning_vi': 'màu đỏ nhạt'},
      {'word': 'purple', 'vi': 'màu tím', 'phonetic': '/ˈpɜːpl/', 'pos': 'noun', 'meaning': 'a mix of red and blue', 'meaning_vi': 'màu pha giữa đỏ và xanh'},
    ],

    'Animals': [
      {'word': 'dog', 'vi': 'con chó', 'phonetic': '/dɒɡ/', 'pos': 'noun', 'meaning': 'a common domestic animal', 'meaning_vi': 'động vật nuôi phổ biến'},
      {'word': 'cat', 'vi': 'con mèo', 'phonetic': '/kæt/', 'pos': 'noun', 'meaning': 'a small domestic animal', 'meaning_vi': 'động vật nuôi nhỏ'},
      {'word': 'bird', 'vi': 'con chim', 'phonetic': '/bɜːd/', 'pos': 'noun', 'meaning': 'an animal that can fly', 'meaning_vi': 'động vật biết bay'},
      {'word': 'fish', 'vi': 'con cá', 'phonetic': '/fɪʃ/', 'pos': 'noun', 'meaning': 'an animal that lives in water', 'meaning_vi': 'động vật sống dưới nước'},
      {'word': 'cow', 'vi': 'con bò', 'phonetic': '/kaʊ/', 'pos': 'noun', 'meaning': 'a farm animal that produces milk', 'meaning_vi': 'động vật nuôi cho sữa'},
      {'word': 'tiger', 'vi': 'con hổ', 'phonetic': '/ˈtaɪɡə/', 'pos': 'noun', 'meaning': 'a large wild cat', 'meaning_vi': 'loài mèo lớn hoang dã'},
      {'word': 'elephant', 'vi': 'con voi', 'phonetic': '/ˈelɪfənt/', 'pos': 'noun', 'meaning': 'the largest land animal', 'meaning_vi': 'động vật lớn nhất trên cạn'},
    ],

    'Objects': [
      {'word': 'table', 'vi': 'cái bàn', 'phonetic': '/ˈteɪbl/', 'pos': 'noun', 'meaning': 'a piece of furniture with a flat top', 'meaning_vi': 'đồ nội thất có mặt phẳng'},
      {'word': 'chair', 'vi': 'cái ghế', 'phonetic': '/tʃeə/', 'pos': 'noun', 'meaning': 'a seat for one person', 'meaning_vi': 'ghế cho một người ngồi'},
      {'word': 'book', 'vi': 'quyển sách', 'phonetic': '/bʊk/', 'pos': 'noun', 'meaning': 'a written or printed work', 'meaning_vi': 'tập hợp trang giấy có nội dung'},
      {'word': 'pen', 'vi': 'cây bút', 'phonetic': '/pen/', 'pos': 'noun', 'meaning': 'a tool used for writing', 'meaning_vi': 'dụng cụ để viết'},
      {'word': 'phone', 'vi': 'điện thoại', 'phonetic': '/fəʊn/', 'pos': 'noun', 'meaning': 'a device for communication', 'meaning_vi': 'thiết bị liên lạc'},
      {'word': 'bag', 'vi': 'cái túi', 'phonetic': '/bæɡ/', 'pos': 'noun', 'meaning': 'container used to carry things', 'meaning_vi': 'vật dùng để đựng đồ'},
    ],

    'Greetings': [
      {'word': 'hello', 'vi': 'xin chào', 'phonetic': '/həˈləʊ/', 'pos': 'interjection', 'meaning': 'used to greet someone', 'meaning_vi': 'lời chào khi gặp'},
      {'word': 'hi', 'vi': 'chào', 'phonetic': '/haɪ/', 'pos': 'interjection', 'meaning': 'informal greeting', 'meaning_vi': 'lời chào thân mật'},
      {'word': 'good morning', 'vi': 'chào buổi sáng', 'phonetic': '/ɡʊd ˈmɔːnɪŋ/', 'pos': 'phrase', 'meaning': 'greeting in the morning', 'meaning_vi': 'lời chào buổi sáng'},
      {'word': 'good afternoon', 'vi': 'chào buổi chiều', 'phonetic': '/ɡʊd ˌɑːftəˈnuːn/', 'pos': 'phrase', 'meaning': 'greeting in the afternoon', 'meaning_vi': 'lời chào buổi chiều'},
      {'word': 'good evening', 'vi': 'chào buổi tối', 'phonetic': '/ɡʊd ˈiːvnɪŋ/', 'pos': 'phrase', 'meaning': 'greeting in the evening', 'meaning_vi': 'lời chào buổi tối'},
      {'word': 'goodbye', 'vi': 'tạm biệt', 'phonetic': '/ˌɡʊdˈbaɪ/', 'pos': 'interjection', 'meaning': 'used when leaving', 'meaning_vi': 'lời chào khi rời đi'},
    ],

    'Time': [
      {'word': 'time', 'vi': 'thời gian', 'phonetic': '/taɪm/', 'pos': 'noun', 'meaning': 'continued progress of existence', 'meaning_vi': 'sự trôi qua của thời gian'},
      {'word': 'hour', 'vi': 'giờ', 'phonetic': '/ˈaʊə/', 'pos': 'noun', 'meaning': '60 minutes', 'meaning_vi': '60 phút'},
      {'word': 'minute', 'vi': 'phút', 'phonetic': '/ˈmɪnɪt/', 'pos': 'noun', 'meaning': '60 seconds', 'meaning_vi': '60 giây'},
      {'word': 'second', 'vi': 'giây', 'phonetic': '/ˈsekənd/', 'pos': 'noun', 'meaning': 'unit of time', 'meaning_vi': 'đơn vị thời gian'},
      {'word': 'day', 'vi': 'ngày', 'phonetic': '/deɪ/', 'pos': 'noun', 'meaning': '24 hours', 'meaning_vi': '24 giờ'},
      {'word': 'week', 'vi': 'tuần', 'phonetic': '/wiːk/', 'pos': 'noun', 'meaning': '7 days', 'meaning_vi': '7 ngày'},
    ],

    'Places': [
      {'word': 'city', 'vi': 'thành phố', 'phonetic': '/ˈsɪti/', 'pos': 'noun', 'meaning': 'large town', 'meaning_vi': 'khu đô thị lớn'},
      {'word': 'village', 'vi': 'làng', 'phonetic': '/ˈvɪlɪdʒ/', 'pos': 'noun', 'meaning': 'small rural community', 'meaning_vi': 'khu dân cư nhỏ'},
      {'word': 'market', 'vi': 'chợ', 'phonetic': '/ˈmɑːkɪt/', 'pos': 'noun', 'meaning': 'place where goods are sold', 'meaning_vi': 'nơi mua bán'},
      {'word': 'restaurant', 'vi': 'nhà hàng', 'phonetic': '/ˈrestrɒnt/', 'pos': 'noun', 'meaning': 'place to eat meals', 'meaning_vi': 'nơi ăn uống'},
      {'word': 'school', 'vi': 'trường học', 'phonetic': '/skuːl/', 'pos': 'noun', 'meaning': 'place for education', 'meaning_vi': 'nơi học tập'},
      {'word': 'park', 'vi': 'công viên', 'phonetic': '/pɑːk/', 'pos': 'noun', 'meaning': 'public green area', 'meaning_vi': 'khu vực cây xanh công cộng'},
    ],

    'Family': [
      {'word': 'father', 'vi': 'bố', 'phonetic': '/ˈfɑːðə/', 'pos': 'noun', 'meaning': 'male parent', 'meaning_vi': 'cha'},
      {'word': 'mother', 'vi': 'mẹ', 'phonetic': '/ˈmʌðə/', 'pos': 'noun', 'meaning': 'female parent', 'meaning_vi': 'mẹ'},
      {'word': 'brother', 'vi': 'anh/em trai', 'phonetic': '/ˈbrʌðə/', 'pos': 'noun', 'meaning': 'a male sibling', 'meaning_vi': 'anh hoặc em trai'},
      {'word': 'sister', 'vi': 'chị/em gái', 'phonetic': '/ˈsɪstə/', 'pos': 'noun', 'meaning': 'a female sibling', 'meaning_vi': 'chị hoặc em gái'},
      {'word': 'parent', 'vi': 'cha mẹ', 'phonetic': '/ˈpeərənt/', 'pos': 'noun', 'meaning': 'father or mother', 'meaning_vi': 'bố hoặc mẹ'},
      {'word': 'child', 'vi': 'đứa trẻ', 'phonetic': '/tʃaɪld/', 'pos': 'noun', 'meaning': 'a young person', 'meaning_vi': 'trẻ nhỏ'},
    ],

    'School': [
      {'word': 'classroom', 'vi': 'lớp học', 'phonetic': '/ˈklɑːsruːm/', 'pos': 'noun', 'meaning': 'room where students learn', 'meaning_vi': 'phòng học'},
      {'word': 'subject', 'vi': 'môn học', 'phonetic': '/ˈsʌbdʒɪkt/', 'pos': 'noun', 'meaning': 'area of study', 'meaning_vi': 'lĩnh vực học'},
      {'word': 'study', 'vi': 'học', 'phonetic': '/ˈstʌdi/', 'pos': 'verb', 'meaning': 'to learn about a subject', 'meaning_vi': 'học tập'},
      {'word': 'library', 'vi': 'thư viện', 'phonetic': '/ˈlaɪbrəri/', 'pos': 'noun', 'meaning': 'place with many books', 'meaning_vi': 'nơi có nhiều sách'},
      {'word': 'notebook', 'vi': 'vở', 'phonetic': '/ˈnəʊtbʊk/', 'pos': 'noun', 'meaning': 'book for writing notes', 'meaning_vi': 'vở ghi'},
      {'word': 'pen', 'vi': 'bút', 'phonetic': '/pen/', 'pos': 'noun', 'meaning': 'tool used for writing', 'meaning_vi': 'dụng cụ viết'},
    ],

    'Sports': [
      {'word': 'football', 'vi': 'bóng đá', 'phonetic': '/ˈfʊtbɔːl/', 'pos': 'noun', 'meaning': 'a popular team sport', 'meaning_vi': 'một môn thể thao đồng đội phổ biến'},
      {'word': 'swimming', 'vi': 'bơi lội', 'phonetic': '/ˈswɪmɪŋ/', 'pos': 'noun', 'meaning': 'moving in water', 'meaning_vi': 'di chuyển trong nước'},
      {'word': 'basketball', 'vi': 'bóng rổ', 'phonetic': '/ˈbɑːskɪtbɔːl/', 'pos': 'noun', 'meaning': 'sport played with a ball and hoop', 'meaning_vi': 'môn thể thao với bóng và rổ'},
      {'word': 'tennis', 'vi': 'quần vợt', 'phonetic': '/ˈtenɪs/', 'pos': 'noun', 'meaning': 'sport played with racket', 'meaning_vi': 'môn thể thao dùng vợt'},
      {'word': 'player', 'vi': 'cầu thủ', 'phonetic': '/ˈpleɪə/', 'pos': 'noun', 'meaning': 'person who plays a sport', 'meaning_vi': 'người chơi thể thao'},
      {'word': 'stadium', 'vi': 'sân vận động', 'phonetic': '/ˈsteɪdiəm/', 'pos': 'noun', 'meaning': 'large sports arena', 'meaning_vi': 'nơi thi đấu thể thao'},
    ],

    'Food': [
      {'word': 'breakfast', 'vi': 'bữa sáng', 'phonetic': '/ˈbrekfəst/', 'pos': 'noun', 'meaning': 'the first meal of the day', 'meaning_vi': 'bữa ăn đầu tiên'},
      {'word': 'lunch', 'vi': 'bữa trưa', 'phonetic': '/lʌntʃ/', 'pos': 'noun', 'meaning': 'a meal in the middle of the day', 'meaning_vi': 'bữa ăn giữa ngày'},
      {'word': 'dinner', 'vi': 'bữa tối', 'phonetic': '/ˈdɪnə/', 'pos': 'noun', 'meaning': 'the main meal of the evening', 'meaning_vi': 'bữa ăn tối'},
      {'word': 'rice', 'vi': 'cơm', 'phonetic': '/raɪs/', 'pos': 'noun', 'meaning': 'a common grain food', 'meaning_vi': 'một loại lương thực phổ biến'},
      {'word': 'bread', 'vi': 'bánh mì', 'phonetic': '/bred/', 'pos': 'noun', 'meaning': 'food made from flour', 'meaning_vi': 'thức ăn làm từ bột'},
      {'word': 'meat', 'vi': 'thịt', 'phonetic': '/miːt/', 'pos': 'noun', 'meaning': 'animal flesh used as food', 'meaning_vi': 'thịt động vật'},
      {'word': 'fruit', 'vi': 'trái cây', 'phonetic': '/fruːt/', 'pos': 'noun', 'meaning': 'sweet food from plants', 'meaning_vi': 'trái cây'},
      {'word': 'delicious', 'vi': 'ngon', 'phonetic': '/dɪˈlɪʃəs/', 'pos': 'adjective', 'meaning': 'tastes very good', 'meaning_vi': 'rất ngon'},
    ],

    'Shopping': [
      {'word': 'shop', 'vi': 'cửa hàng', 'phonetic': '/ʃɒp/', 'pos': 'noun', 'meaning': 'place where goods are sold', 'meaning_vi': 'nơi bán hàng'},
      {'word': 'price', 'vi': 'giá', 'phonetic': '/praɪs/', 'pos': 'noun', 'meaning': 'amount of money for something', 'meaning_vi': 'số tiền phải trả'},
      {'word': 'buy', 'vi': 'mua', 'phonetic': '/baɪ/', 'pos': 'verb', 'meaning': 'get something by paying', 'meaning_vi': 'mua bằng tiền'},
      {'word': 'sell', 'vi': 'bán', 'phonetic': '/sel/', 'pos': 'verb', 'meaning': 'give something for money', 'meaning_vi': 'bán hàng'},
      {'word': 'customer', 'vi': 'khách hàng', 'phonetic': '/ˈkʌstəmə/', 'pos': 'noun', 'meaning': 'person who buys goods', 'meaning_vi': 'người mua hàng'},
      {'word': 'discount', 'vi': 'giảm giá', 'phonetic': '/ˈdɪskaʊnt/', 'pos': 'noun', 'meaning': 'reduction in price', 'meaning_vi': 'giảm giá'},
    ],

    'Transport': [
      {'word': 'bus', 'vi': 'xe buýt', 'phonetic': '/bʌs/', 'pos': 'noun', 'meaning': 'a public vehicle', 'meaning_vi': 'phương tiện giao thông công cộng'},
      {'word': 'train', 'vi': 'tàu hỏa', 'phonetic': '/treɪn/', 'pos': 'noun', 'meaning': 'a railway vehicle', 'meaning_vi': 'phương tiện đường sắt'},
      {'word': 'car', 'vi': 'ô tô', 'phonetic': '/kɑː/', 'pos': 'noun', 'meaning': 'road vehicle with four wheels', 'meaning_vi': 'xe ô tô'},
      {'word': 'motorbike', 'vi': 'xe máy', 'phonetic': '/ˈməʊtəbaɪk/', 'pos': 'noun', 'meaning': 'two-wheeled motor vehicle', 'meaning_vi': 'xe máy hai bánh'},
      {'word': 'bicycle', 'vi': 'xe đạp', 'phonetic': '/ˈbaɪsɪkl/', 'pos': 'noun', 'meaning': 'vehicle powered by pedals', 'meaning_vi': 'xe đạp'},
      {'word': 'airport', 'vi': 'sân bay', 'phonetic': '/ˈeəpɔːt/', 'pos': 'noun', 'meaning': 'place where planes land', 'meaning_vi': 'nơi máy bay cất cánh và hạ cánh'},
    ],

    'Weather': [
      {'word': 'rain', 'vi': 'mưa', 'phonetic': '/reɪn/', 'pos': 'noun', 'meaning': 'water falling from the sky', 'meaning_vi': 'nước rơi từ bầu trời'},
      {'word': 'sunny', 'vi': 'nắng', 'phonetic': '/ˈsʌni/', 'pos': 'adjective', 'meaning': 'full of sunshine', 'meaning_vi': 'đầy ánh nắng'},
      {'word': 'cloudy', 'vi': 'nhiều mây', 'phonetic': '/ˈklaʊdi/', 'pos': 'adjective', 'meaning': 'covered with clouds', 'meaning_vi': 'trời nhiều mây'},
      {'word': 'windy', 'vi': 'có gió', 'phonetic': '/ˈwɪndi/', 'pos': 'adjective', 'meaning': 'with strong wind', 'meaning_vi': 'có nhiều gió'},
      {'word': 'storm', 'vi': 'bão', 'phonetic': '/stɔːm/', 'pos': 'noun', 'meaning': 'violent weather', 'meaning_vi': 'thời tiết dữ dội'},
      {'word': 'temperature', 'vi': 'nhiệt độ', 'phonetic': '/ˈtemprətʃə/', 'pos': 'noun', 'meaning': 'measure of heat', 'meaning_vi': 'mức độ nóng lạnh'},
    ],

    // ===== HSK 5 =====
    'Travel': [
      {'word': 'journey', 'vi': 'chuyến đi', 'phonetic': '/ˈdʒɜːni/', 'pos': 'noun', 'meaning': 'act of travelling', 'meaning_vi': 'việc đi lại'},
      {'word': 'tourist', 'vi': 'khách du lịch', 'phonetic': '/ˈtʊərɪst/', 'pos': 'noun', 'meaning': 'person travelling for pleasure', 'meaning_vi': 'người đi du lịch'},
      {'word': 'destination', 'vi': 'điểm đến', 'phonetic': '/ˌdestɪˈneɪʃn/', 'pos': 'noun', 'meaning': 'place someone travels to', 'meaning_vi': 'nơi đến'},
      {'word': 'passport', 'vi': 'hộ chiếu', 'phonetic': '/ˈpɑːspɔːt/', 'pos': 'noun', 'meaning': 'official travel document', 'meaning_vi': 'giấy tờ đi nước ngoài'},
      {'word': 'airport', 'vi': 'sân bay', 'phonetic': '/ˈeəpɔːt/', 'pos': 'noun', 'meaning': 'place where planes land', 'meaning_vi': 'nơi máy bay cất hạ cánh'},
      {'word': 'luggage', 'vi': 'hành lý', 'phonetic': '/ˈlʌɡɪdʒ/', 'pos': 'noun', 'meaning': 'bags used for travel', 'meaning_vi': 'đồ mang theo khi đi'},
    ],

    'Work': [
      {'word': 'job', 'vi': 'công việc', 'phonetic': '/dʒɒb/', 'pos': 'noun', 'meaning': 'paid position', 'meaning_vi': 'công việc được trả lương'},
      {'word': 'office', 'vi': 'văn phòng', 'phonetic': '/ˈɒfɪs/', 'pos': 'noun', 'meaning': 'place where people work', 'meaning_vi': 'nơi làm việc'},
      {'word': 'task', 'vi': 'nhiệm vụ', 'phonetic': '/tɑːsk/', 'pos': 'noun', 'meaning': 'piece of work', 'meaning_vi': 'công việc phải làm'},
      {'word': 'career', 'vi': 'sự nghiệp', 'phonetic': '/kəˈrɪə/', 'pos': 'noun', 'meaning': 'long-term profession', 'meaning_vi': 'con đường nghề nghiệp'},
      {'word': 'colleague', 'vi': 'đồng nghiệp', 'phonetic': '/ˈkɒliːɡ/', 'pos': 'noun', 'meaning': 'person you work with', 'meaning_vi': 'người làm cùng'},
      {'word': 'meeting', 'vi': 'cuộc họp', 'phonetic': '/ˈmiːtɪŋ/', 'pos': 'noun', 'meaning': 'gathering for discussion', 'meaning_vi': 'buổi họp'},
    ],

    'Media': [
      {'word': 'broadcast', 'vi': 'phát sóng', 'phonetic': '/ˈbrɔːdkɑːst/', 'pos': 'verb', 'meaning': 'send programs by TV or radio', 'meaning_vi': 'phát chương trình'},
      {'word': 'journalist', 'vi': 'nhà báo', 'phonetic': '/ˈdʒɜːnəlɪst/', 'pos': 'noun', 'meaning': 'person who reports news', 'meaning_vi': 'người làm báo'},
      {'word': 'news', 'vi': 'tin tức', 'phonetic': '/njuːz/', 'pos': 'noun', 'meaning': 'information about recent events', 'meaning_vi': 'thông tin sự kiện mới'},
      {'word': 'report', 'vi': 'bản tin', 'phonetic': '/rɪˈpɔːt/', 'pos': 'noun', 'meaning': 'detailed news story', 'meaning_vi': 'bản báo cáo tin tức'},
      {'word': 'television', 'vi': 'tivi', 'phonetic': '/ˈtelɪvɪʒn/', 'pos': 'noun', 'meaning': 'device for watching programs', 'meaning_vi': 'thiết bị xem chương trình'},
      {'word': 'interview', 'vi': 'phỏng vấn', 'phonetic': '/ˈɪntəvjuː/', 'pos': 'noun', 'meaning': 'formal meeting for questions', 'meaning_vi': 'buổi hỏi đáp'},
    ],

    'Lifestyle': [
      {'word': 'routine', 'vi': 'thói quen hàng ngày', 'phonetic': '/ruːˈtiːn/', 'pos': 'noun', 'meaning': 'daily habits', 'meaning_vi': 'thói quen mỗi ngày'},
      {'word': 'balance', 'vi': 'sự cân bằng', 'phonetic': '/ˈbæləns/', 'pos': 'noun', 'meaning': 'state of harmony', 'meaning_vi': 'trạng thái cân bằng'},
      {'word': 'exercise', 'vi': 'tập thể dục', 'phonetic': '/ˈeksəsaɪz/', 'pos': 'noun', 'meaning': 'physical activity for health', 'meaning_vi': 'hoạt động thể chất'},
      {'word': 'diet', 'vi': 'chế độ ăn', 'phonetic': '/ˈdaɪət/', 'pos': 'noun', 'meaning': 'food habit', 'meaning_vi': 'thói quen ăn uống'},
      {'word': 'healthy', 'vi': 'khỏe mạnh', 'phonetic': '/ˈhelθi/', 'pos': 'adjective', 'meaning': 'in good health', 'meaning_vi': 'có sức khỏe tốt'},
      {'word': 'relax', 'vi': 'thư giãn', 'phonetic': '/rɪˈlæks/', 'pos': 'verb', 'meaning': 'to rest and feel calm', 'meaning_vi': 'nghỉ ngơi thư giãn'},
    ],

    // ===== HSK 6 =====
    'Technology': [
      {'word': 'software', 'vi': 'phần mềm', 'phonetic': '/ˈsɒftweə/', 'pos': 'noun', 'meaning': 'computer programs', 'meaning_vi': 'các chương trình máy tính'},
      {'word': 'hardware', 'vi': 'phần cứng', 'phonetic': '/ˈhɑːdweə/', 'pos': 'noun', 'meaning': 'physical parts of a computer', 'meaning_vi': 'các bộ phận vật lý của máy tính'},
      {'word': 'database', 'vi': 'cơ sở dữ liệu', 'phonetic': '/ˈdeɪtəbeɪs/', 'pos': 'noun', 'meaning': 'organized data collection', 'meaning_vi': 'tập hợp dữ liệu'},
      {'word': 'algorithm', 'vi': 'thuật toán', 'phonetic': '/ˈælɡərɪðəm/', 'pos': 'noun', 'meaning': 'rules to solve problems', 'meaning_vi': 'quy tắc giải quyết vấn đề'},
      {'word': 'internet', 'vi': 'mạng internet', 'phonetic': '/ˈɪntənet/', 'pos': 'noun', 'meaning': 'global computer network', 'meaning_vi': 'mạng máy tính toàn cầu'},
      {'word': 'application', 'vi': 'ứng dụng', 'phonetic': '/ˌæplɪˈkeɪʃn/', 'pos': 'noun', 'meaning': 'software program', 'meaning_vi': 'chương trình ứng dụng'},
    ],

    'Business': [
      {'word': 'investment', 'vi': 'đầu tư', 'phonetic': '/ɪnˈvestmənt/', 'pos': 'noun', 'meaning': 'putting money into business', 'meaning_vi': 'bỏ tiền đầu tư'},
      {'word': 'profit', 'vi': 'lợi nhuận', 'phonetic': '/ˈprɒfɪt/', 'pos': 'noun', 'meaning': 'money earned after costs', 'meaning_vi': 'tiền sau khi trừ chi phí'},
      {'word': 'company', 'vi': 'công ty', 'phonetic': '/ˈkʌmpəni/', 'pos': 'noun', 'meaning': 'a business organization', 'meaning_vi': 'tổ chức kinh doanh'},
      {'word': 'manager', 'vi': 'quản lý', 'phonetic': '/ˈmænɪdʒə/', 'pos': 'noun', 'meaning': 'person who manages', 'meaning_vi': 'người quản lý'},
      {'word': 'employee', 'vi': 'nhân viên', 'phonetic': '/ˌemplɔɪˈiː/', 'pos': 'noun', 'meaning': 'person who works for company', 'meaning_vi': 'người làm việc cho công ty'},
      {'word': 'salary', 'vi': 'lương', 'phonetic': '/ˈsæləri/', 'pos': 'noun', 'meaning': 'regular payment for work', 'meaning_vi': 'tiền lương'},
    ],

    'Education': [
      {'word': 'school', 'vi': 'trường học', 'phonetic': '/skuːl/', 'pos': 'noun', 'meaning': 'place where students study', 'meaning_vi': 'nơi học sinh học tập'},
      {'word': 'teacher', 'vi': 'giáo viên', 'phonetic': '/ˈtiːtʃə/', 'pos': 'noun', 'meaning': 'person who teaches', 'meaning_vi': 'người dạy học'},
      {'word': 'student', 'vi': 'học sinh', 'phonetic': '/ˈstjuːdənt/', 'pos': 'noun', 'meaning': 'person who studies', 'meaning_vi': 'người học'},
      {'word': 'lesson', 'vi': 'bài học', 'phonetic': '/ˈlesn/', 'pos': 'noun', 'meaning': 'a period of learning', 'meaning_vi': 'một buổi học'},
      {'word': 'homework', 'vi': 'bài tập về nhà', 'phonetic': '/ˈhəʊmwɜːk/', 'pos': 'noun', 'meaning': 'work students do at home', 'meaning_vi': 'bài tập làm ở nhà'},
      {'word': 'exam', 'vi': 'kỳ thi', 'phonetic': '/ɪɡˈzæm/', 'pos': 'noun', 'meaning': 'a test of knowledge', 'meaning_vi': 'bài kiểm tra'},
    ],

    'Health': [
      {'word': 'doctor', 'vi': 'bác sĩ', 'phonetic': '/ˈdɒktə/', 'pos': 'noun', 'meaning': 'medical professional', 'meaning_vi': 'người chữa bệnh'},
      {'word': 'hospital', 'vi': 'bệnh viện', 'phonetic': '/ˈhɒspɪtl/', 'pos': 'noun', 'meaning': 'place for medical care', 'meaning_vi': 'nơi chữa bệnh'},
      {'word': 'medicine', 'vi': 'thuốc', 'phonetic': '/ˈmedsn/', 'pos': 'noun', 'meaning': 'drug used for treatment', 'meaning_vi': 'thuốc chữa bệnh'},
      {'word': 'exercise', 'vi': 'tập thể dục', 'phonetic': '/ˈeksəsaɪz/', 'pos': 'noun', 'meaning': 'physical activity for health', 'meaning_vi': 'hoạt động rèn luyện'},
      {'word': 'healthy', 'vi': 'khỏe mạnh', 'phonetic': '/ˈhelθi/', 'pos': 'adj', 'meaning': 'in good health', 'meaning_vi': 'khỏe mạnh'},
      {'word': 'disease', 'vi': 'bệnh', 'phonetic': '/dɪˈziːz/', 'pos': 'noun', 'meaning': 'illness affecting body', 'meaning_vi': 'căn bệnh'},
    ],

    'Environment': [
      {'word': 'nature', 'vi': 'thiên nhiên', 'phonetic': '/ˈneɪtʃə/', 'pos': 'noun', 'meaning': 'the natural world', 'meaning_vi': 'thế giới tự nhiên'},
      {'word': 'pollution', 'vi': 'ô nhiễm', 'phonetic': '/pəˈluːʃn/', 'pos': 'noun', 'meaning': 'harmful substances in environment', 'meaning_vi': 'sự ô nhiễm'},
      {'word': 'climate', 'vi': 'khí hậu', 'phonetic': '/ˈklaɪmət/', 'pos': 'noun', 'meaning': 'weather conditions', 'meaning_vi': 'điều kiện thời tiết'},
      {'word': 'recycle', 'vi': 'tái chế', 'phonetic': '/ˌriːˈsaɪkl/', 'pos': 'verb', 'meaning': 'reuse materials', 'meaning_vi': 'tái sử dụng'},
      {'word': 'forest', 'vi': 'rừng', 'phonetic': '/ˈfɒrɪst/', 'pos': 'noun', 'meaning': 'large area of trees', 'meaning_vi': 'khu vực nhiều cây'},
      {'word': 'wildlife', 'vi': 'động vật hoang dã', 'phonetic': '/ˈwaɪldlaɪf/', 'pos': 'noun', 'meaning': 'animals living in nature', 'meaning_vi': 'động vật tự nhiên'},
    ],

    // ===== HSK 7–9 =====
    'Politics': [
      {'word': 'government', 'vi': 'chính phủ', 'phonetic': '/ˈɡʌvənmənt/', 'pos': 'noun', 'meaning': 'group that rules a country', 'meaning_vi': 'cơ quan điều hành quốc gia'},
      {'word': 'policy', 'vi': 'chính sách', 'phonetic': '/ˈpɒləsi/', 'pos': 'noun', 'meaning': 'official plan of action', 'meaning_vi': 'kế hoạch hành động chính thức'},
      {'word': 'election', 'vi': 'bầu cử', 'phonetic': '/ɪˈlekʃn/', 'pos': 'noun', 'meaning': 'process of choosing leaders', 'meaning_vi': 'quá trình chọn lãnh đạo'},
      {'word': 'democracy', 'vi': 'dân chủ', 'phonetic': '/dɪˈmɒkrəsi/', 'pos': 'noun', 'meaning': 'system where people vote', 'meaning_vi': 'hệ thống người dân bầu chọn'},
      {'word': 'law', 'vi': 'luật', 'phonetic': '/lɔː/', 'pos': 'noun', 'meaning': 'rules of a country', 'meaning_vi': 'quy tắc của quốc gia'},
      {'word': 'leader', 'vi': 'lãnh đạo', 'phonetic': '/ˈliːdə/', 'pos': 'noun', 'meaning': 'person who leads a group', 'meaning_vi': 'người dẫn dắt'},
    ],

    'Economy': [
      {'word': 'economy', 'vi': 'nền kinh tế', 'phonetic': '/ɪˈkɒnəmi/', 'pos': 'noun', 'meaning': 'system of production and trade', 'meaning_vi': 'hệ thống sản xuất và thương mại'},
      {'word': 'inflation', 'vi': 'lạm phát', 'phonetic': '/ɪnˈfleɪʃn/', 'pos': 'noun', 'meaning': 'increase in prices over time', 'meaning_vi': 'sự tăng giá chung'},
      {'word': 'tax', 'vi': 'thuế', 'phonetic': '/tæks/', 'pos': 'noun', 'meaning': 'money paid to the government', 'meaning_vi': 'khoản tiền nộp cho nhà nước'},
      {'word': 'market', 'vi': 'thị trường', 'phonetic': '/ˈmɑːkɪt/', 'pos': 'noun', 'meaning': 'place for buying and selling', 'meaning_vi': 'nơi mua bán hàng hóa'},
      {'word': 'trade', 'vi': 'thương mại', 'phonetic': '/treɪd/', 'pos': 'noun', 'meaning': 'exchange of goods and services', 'meaning_vi': 'trao đổi hàng hóa'},
      {'word': 'budget', 'vi': 'ngân sách', 'phonetic': '/ˈbʌdʒɪt/', 'pos': 'noun', 'meaning': 'financial plan', 'meaning_vi': 'kế hoạch chi tiêu'},
    ],

    'Law': [
      {'word': 'law', 'vi': 'luật', 'phonetic': '/lɔː/', 'pos': 'noun', 'meaning': 'system of rules', 'meaning_vi': 'hệ thống quy tắc'},
      {'word': 'judge', 'vi': 'thẩm phán', 'phonetic': '/dʒʌdʒ/', 'pos': 'noun', 'meaning': 'person who decides cases', 'meaning_vi': 'người xét xử'},
      {'word': 'lawyer', 'vi': 'luật sư', 'phonetic': '/ˈlɔːjə/', 'pos': 'noun', 'meaning': 'person practicing law', 'meaning_vi': 'người hành nghề luật'},
      {'word': 'court', 'vi': 'tòa án', 'phonetic': '/kɔːt/', 'pos': 'noun', 'meaning': 'place for legal cases', 'meaning_vi': 'nơi xét xử'},
      {'word': 'crime', 'vi': 'tội phạm', 'phonetic': '/kraɪm/', 'pos': 'noun', 'meaning': 'illegal act', 'meaning_vi': 'hành vi phạm pháp'},
      {'word': 'justice', 'vi': 'công lý', 'phonetic': '/ˈdʒʌstɪs/', 'pos': 'noun', 'meaning': 'fairness according to law', 'meaning_vi': 'sự công bằng theo luật'},
    ],

    'Philosophy': [
      {'word': 'philosophy', 'vi': 'triết học', 'phonetic': '/fɪˈlɒsəfi/', 'pos': 'noun', 'meaning': 'study of fundamental ideas', 'meaning_vi': 'nghiên cứu các vấn đề cơ bản'},
      {'word': 'ethics', 'vi': 'đạo đức', 'phonetic': '/ˈeθɪks/', 'pos': 'noun', 'meaning': 'moral principles', 'meaning_vi': 'nguyên tắc đạo đức'},
      {'word': 'wisdom', 'vi': 'trí tuệ', 'phonetic': '/ˈwɪzdəm/', 'pos': 'noun', 'meaning': 'deep understanding', 'meaning_vi': 'sự hiểu biết sâu sắc'},
      {'word': 'belief', 'vi': 'niềm tin', 'phonetic': '/bɪˈliːf/', 'pos': 'noun', 'meaning': 'accepting something as true', 'meaning_vi': 'sự tin tưởng'},
      {'word': 'logic', 'vi': 'logic', 'phonetic': '/ˈlɒdʒɪk/', 'pos': 'noun', 'meaning': 'reasoning process', 'meaning_vi': 'quá trình suy luận'},
      {'word': 'existence', 'vi': 'sự tồn tại', 'phonetic': '/ɪɡˈzɪstəns/', 'pos': 'noun', 'meaning': 'state of being alive or real', 'meaning_vi': 'trạng thái tồn tại'},
    ],

    'Research': [
      {'word': 'research', 'vi': 'nghiên cứu', 'phonetic': '/rɪˈsɜːtʃ/', 'pos': 'noun', 'meaning': 'systematic investigation', 'meaning_vi': 'quá trình nghiên cứu'},
      {'word': 'experiment', 'vi': 'thí nghiệm', 'phonetic': '/ɪkˈsperɪmənt/', 'pos': 'noun', 'meaning': 'scientific test', 'meaning_vi': 'bài kiểm tra khoa học'},
      {'word': 'data', 'vi': 'dữ liệu', 'phonetic': '/ˈdeɪtə/', 'pos': 'noun', 'meaning': 'facts used for analysis', 'meaning_vi': 'thông tin phân tích'},
      {'word': 'analysis', 'vi': 'phân tích', 'phonetic': '/əˈnæləsɪs/', 'pos': 'noun', 'meaning': 'detailed examination', 'meaning_vi': 'xem xét chi tiết'},
      {'word': 'theory', 'vi': 'lý thuyết', 'phonetic': '/ˈθɪəri/', 'pos': 'noun', 'meaning': 'system of ideas', 'meaning_vi': 'hệ thống ý tưởng'},
      {'word': 'discovery', 'vi': 'phát hiện', 'phonetic': '/dɪˈskʌvəri/', 'pos': 'noun', 'meaning': 'finding something new', 'meaning_vi': 'tìm ra điều mới'},
    ],

    'Culture': [
      {'word': 'tradition', 'vi': 'truyền thống', 'phonetic': '/trəˈdɪʃn/', 'pos': 'noun', 'meaning': 'custom passed through generations', 'meaning_vi': 'tập quán truyền lại'},
      {'word': 'festival', 'vi': 'lễ hội', 'phonetic': '/ˈfestɪvl/', 'pos': 'noun', 'meaning': 'public celebration', 'meaning_vi': 'sự kiện lễ hội'},
      {'word': 'custom', 'vi': 'phong tục', 'phonetic': '/ˈkʌstəm/', 'pos': 'noun', 'meaning': 'traditional behavior', 'meaning_vi': 'tập quán'},
      {'word': 'religion', 'vi': 'tôn giáo', 'phonetic': '/rɪˈlɪdʒən/', 'pos': 'noun', 'meaning': 'belief system', 'meaning_vi': 'niềm tin tôn giáo'},
      {'word': 'heritage', 'vi': 'di sản', 'phonetic': '/ˈherɪtɪdʒ/', 'pos': 'noun', 'meaning': 'cultural inheritance', 'meaning_vi': 'di sản văn hóa'},
      {'word': 'ceremony', 'vi': 'nghi lễ', 'phonetic': '/ˈserəməni/', 'pos': 'noun', 'meaning': 'formal event', 'meaning_vi': 'sự kiện nghi thức'},
    ],
  };

  final hskData = [
    {
      'level': 'IELTS7-9',
      'total': 300,
      'lessons': 20,
      'topics': [
        {'title': 'Politics', 'icon': Icons.account_balance},
        {'title': 'Economy', 'icon': Icons.trending_up},
        {'title': 'Law', 'icon': Icons.gavel},
        {'title': 'Philosophy', 'icon': Icons.psychology},
        {'title': 'Research', 'icon': Icons.science},
        {'title': 'Culture', 'icon': Icons.public},
      ]
    },
    {
      'level': 'IELTS6',
      'total': 250,
      'lessons': 18,
      'topics': [
        {'title': 'Business', 'icon': Icons.business_center},
        {'title': 'Technology', 'icon': Icons.computer},
        {'title': 'Health', 'icon': Icons.health_and_safety},
        {'title': 'Environment', 'icon': Icons.eco},
        {'title': 'Education', 'icon': Icons.school},
      ]
    },
    {
      'level': 'IELTS5',
      'total': 200,
      'lessons': 16,
      'topics': [
        {'title': 'Work', 'icon': Icons.work},
        {'title': 'Travel', 'icon': Icons.flight_takeoff},
        {'title': 'Media', 'icon': Icons.movie},
        {'title': 'Lifestyle', 'icon': Icons.self_improvement},
      ]
    },
    {
      'level': 'IELTS4',
      'total': 180,
      'lessons': 15,
      'topics': [
        {'title': 'Food', 'icon': Icons.restaurant},
        {'title': 'Shopping', 'icon': Icons.shopping_bag},
        {'title': 'Transport', 'icon': Icons.directions_bus},
        {'title': 'Weather', 'icon': Icons.cloud},
      ]
    },
    {
      'level': 'IELTS3',
      'total': 150,
      'lessons': 14,
      'topics': [
        {'title': 'Family', 'icon': Icons.family_restroom},
        {'title': 'School', 'icon': Icons.menu_book},
        {'title': 'Sports', 'icon': Icons.sports_soccer},
      ]
    },
    {
      'level': 'IELTS2',
      'total': 150,
      'lessons': 14,
      'topics': [
        {'title': 'Greetings', 'icon': Icons.waving_hand},
        {'title': 'Time', 'icon': Icons.access_time},
        {'title': 'Places', 'icon': Icons.place},
      ]
    },
    {
      'level': 'IELTS1',
      'total': 150,
      'lessons': 14,
      'topics': [
        {'title': 'Colors', 'icon': Icons.palette},
        {'title': 'Animals', 'icon': Icons.pets},
        {'title': 'Objects', 'icon': Icons.category},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: hskData.length,
      initialIndex: hskData.length - 1,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(hskData.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTopCardByIndex(index),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                _buildTopicGridSliver(index),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildStartButton(context),
      ),
    );
  }

  // ===== AppBar =====
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Từ vựng IELTS',
        style: TextStyle(color: Colors.white, fontSize: 17),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: VocabularySearchDelegate(topicVocabularyData),
            );
          },
        ),
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_horiz),
          color: cardColor,
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: const [
                  Icon(Icons.star, color: Colors.yellow, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Chữ Tiếng Anh đã lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: const [
                  Icon(Icons.book, color: Colors.blue, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Từ mới',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 1) {
              // TODO: reset progress
            } else if (value == 2) {
              // TODO: show info
            }
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        dividerColor: Colors.transparent,
        indicatorColor: Color(0xFF3B82F6),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs:
        hskData.map((e) => Tab(text: e['level'] as String)).toList(),
      ),
    );
  }

  // ===== Top Card =====
  Widget _buildTopCardByIndex(int index) {
    final current = hskData[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.book, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Từ vựng mới ${current['level']} (${current['total']})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '0 / ${current['total']}    ⭐ 0 / ${current['lessons']}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverGrid _buildTopicGridSliver(int index) {
    final topics = hskData[index]['topics'] as List<Map>;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
            (context, i) {
          final topic = topics[i];
          final topicTitle = topic['title'];

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final vocabByTopic =
                  topicVocabularyData[topicTitle] ?? [];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TopicVocabularyScreen(
                    topicName: topicTitle,
                    vocabularies: vocabByTopic,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderBlue, width: 1.2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      topic['icon'],
                      color: primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    topicTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: topics.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
    );
  }

  // ===== Footer Button =====
  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          final currentLevel = hskData[_tabController.index];
          final topics = currentLevel['topics'] as List<Map>;

          if (topics.isEmpty) return;

          // 👉 chủ đề đầu tiên của level
          final firstTopic = topics.first;
          final topicTitle = firstTopic['title'];

          final vocabularies = topicVocabularyData[topicTitle] ?? [];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicVocabularyScreen(
                topicName: topicTitle,
                vocabularies: vocabularies,
              ),
            ),
          );
        },
        child: const Text(
          'Bắt đầu luyện tập',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ===== SEARCH DELEGATE =====
class VocabularySearchDelegate extends SearchDelegate {
  final Map<String, List<Map<String, dynamic>>> topicVocabularyData;

  VocabularySearchDelegate(this.topicVocabularyData);

  @override
  String get searchFieldLabel => 'Tìm từ, dịch nghĩa, ví dụ';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const SizedBox();
    }
    return _buildResultList(context);
  }

  Widget _buildResultList(BuildContext context) {
    final results = <Map<String, dynamic>>[];

    topicVocabularyData.forEach((topic, list) {
      for (var v in list) {
        if (v['word']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          results.add({
            ...v,
            '__topic': topic,
            '__topicList': list,
          });
        }
      }
    });

    if (results.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy từ',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];

        return ListTile(
          title: Text(
            item['word'],
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            '${item['phonetic']} • ${item['meaning']}',
            style: const TextStyle(color: Colors.white54),
          ),
          onTap: () {
            final vocabList =
            item['__topicList'] as List<Map<String, dynamic>>;

            final startIndex = vocabList.indexWhere(
                  (e) => e['word'] == item['word'],
            );

            close(context, null);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabularyDetailScreen(
                  vocabularies: vocabList,
                  initialIndex: startIndex,
                ),
              ),
            );
          },
        );
      },
    );
  }
}