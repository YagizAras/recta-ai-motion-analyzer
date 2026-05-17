import 'package:flutter_bloc/flutter_bloc.dart';
import 'exercise_detail_event.dart';
import 'exercise_detail_state.dart';

class ExerciseDetailBloc extends Bloc<ExerciseDetailEvent, ExerciseDetailState> {
  ExerciseDetailBloc() : super(ExerciseDetailInitial()) {
    on<LoadExerciseDetailEvent>((event, emit) async {
      emit(ExerciseDetailLoading());
      
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        
        List<InstructionStep> instructions = [];
        String alertMessage = "";

        switch (event.exerciseName.toUpperCase()) {
          case "SQUAT":
            instructions = [
              InstructionStep(stepNumber: "1", text: "Ayaklarını omuz genişliğinde aç."),
              InstructionStep(stepNumber: "2", text: "Sırtını düz tutarak kalçanı geriye it."),
              InstructionStep(stepNumber: "3", text: "Dizlerin parmak uçlarını geçmeyecek şekilde alçal."),
              InstructionStep(stepNumber: "4", text: "Uylukların yere paralel olana kadar in, sonra yukarı itin."),
            ];
            alertMessage = "Dizlerini içe doğru bükmekten kaçın, bu bağlarına zarar verebilir.";
            break;

          case "LUNGE":
            instructions = [
              InstructionStep(stepNumber: "1", text: "Düz dur ve bir bacağınla öne büyük bir adım at."),
              InstructionStep(stepNumber: "2", text: "Arkadaki dizini yere yaklaşana kadar kalçanı aşağı indir."),
              InstructionStep(stepNumber: "3", text: "Öndeki dizinin ayak parmak ucunu geçmediğinden emin ol."),
              InstructionStep(stepNumber: "4", text: "Başlangıç pozisyonuna geri dön ve diğer bacakla tekrarla."),
            ];
            alertMessage = "Gövdeni dik tutmaya çalış, öne doğru eğilmekten kaçın.";
            break;

          case "PLANK":
            instructions = [
              InstructionStep(stepNumber: "1", text: "Yüzüstü yere uzan ve dirseklerin üzerinde dur."),
              InstructionStep(stepNumber: "2", text: "Vücudunu düz bir çizgi halinde havaya kaldır."),
              InstructionStep(stepNumber: "3", text: "Karın kaslarını sıkarak bu pozisyonda bekle."),
              InstructionStep(stepNumber: "4", text: "Başından topuklarına kadar düz bir hat oluştur."),
            ];
            alertMessage = "Belini çok fazla aşağı düşürme veya yukarı kaldırma.";
            break;

          case "BASKETBOL ŞUT":
            instructions = [
              InstructionStep(stepNumber: "1", text: "Topu dominant elin üzerinde, diğer el yanında destek olacak şekilde tut."),
              InstructionStep(stepNumber: "2", text: "Atış dirseğini 90° bükerek topu göz hizasına getir."),
              InstructionStep(stepNumber: "3", text: "Dizlerini hafifçe kırarak sıçrama için hazırlan."),
              InstructionStep(stepNumber: "4", text: "Bacaklardan gelen güçle sıçra ve dirseğini düzelterek topu bırak."),
              InstructionStep(stepNumber: "5", text: "Bileğini aşağı doğru kırarak takip hareketi (follow-through) yap."),
            ];
            alertMessage = "Dirseğini dışarıya açmaktan kaçın — dirsek, omuz ve bilek aynı düzlemde olmalı.";
            break;

          case "OMUZ FLEKSİYONU":
            instructions = [
              InstructionStep(stepNumber: "1", text: "Düz dur, kollarını yanlara bırak."),
              InstructionStep(stepNumber: "2", text: "Kolunu düz tutarak yavaşça yukarı kaldır."),
              InstructionStep(stepNumber: "3", text: "Mümkün olduğunca yukarıya, kulağının yanına kadar ulaş."),
              InstructionStep(stepNumber: "4", text: "Yavaşça başlangıç pozisyonuna dön ve diğer kolda tekrarla."),
            ];
            alertMessage = "Hareketi hızlı yapmaktan kaçın, omuz ağrısı hissedersen dur.";
            break;

          case "KEDİ-İNEK":
            instructions = [
              InstructionStep(stepNumber: "1", text: "Eller ve dizler üzerinde masa pozisyonunu al."),
              InstructionStep(stepNumber: "2", text: "Nefes verirken sırtını yukarı yuvarlayarak (kedi) çeneni göğsüne doğru çek."),
              InstructionStep(stepNumber: "3", text: "Nefes alırken göbeğini aşağı düşürerek (inek) başını yukarı kaldır."),
              InstructionStep(stepNumber: "4", text: "Bu döngüyü yavaş ve kontrollü bir şekilde tekrarla."),
            ];
            alertMessage = "Hareketi boyun bölgesinden zorlamak yerine, tüm omurgadan hisset.";
            break;

          default:
            instructions = [
              InstructionStep(stepNumber: "1", text: "Doğru pozisyonu al."),
              InstructionStep(stepNumber: "2", text: "Hareketi yavaş ve kontrollü bir şekilde gerçekleştir."),
              InstructionStep(stepNumber: "3", text: "Nefes alışverişini düzenli tut."),
            ];
            alertMessage = "Egzersiz sırasında ani hareketlerden kaçın.";
        }

        emit(ExerciseDetailLoaded(instructions: instructions, alertMessage: alertMessage));
      } catch (e) {
        emit(ExerciseDetailError("Detaylar yüklenirken hata oluştu."));
      }
    });
  }
}
