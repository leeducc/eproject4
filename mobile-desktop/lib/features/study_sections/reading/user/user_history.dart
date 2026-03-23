class UserHistory {

  // lưu câu làm sai
  static Set<int> wrongQuestions = {};

  // lưu câu làm đúng
  static Set<int> correctQuestions = {};

  static void markWrong(int id) {
    wrongQuestions.add(id);
  }

  static void markCorrect(int id) {
    correctQuestions.add(id);
  }

}