'use strict';
var RNOpenCV = require('react-native').NativeModules.RNOpenCV;

module.exports = {
  faceDataInImage(path) {
    return RNOpenCV.faceData(path);
  },
  faceImage(pathIn,pathOut){
    return RNOpenCV.faceImage(pathIn,pathOut);
  },
  cardDataInImage(path) {
    return RNOpenCV.cardData(path);
  },
  cardImage(pathIn,pathOut){
    return RNOpenCV.cardImage(pathIn,pathOut);
  },
};
