local _={}
_[16]={80,16,16,16}
_[15]={64,16,16,16}
_[14]={48,16,16,16}
_[13]={32,16,16,16}
_[12]={16,16,16,16}
_[11]={0,16,16,16}
_[10]={80,0,16,16}
_[9]={64,0,16,16}
_[8]={48,0,16,16}
_[7]={32,0,16,16}
_[6]={16,0,16,16}
_[5]={0,0,16,16}
_[4]={stframe=6,enframe=11,name="walk"}
_[3]={stframe=0,enframe=3,name="idle"}
_[2]={_[5],_[6],_[7],_[8],_[9],_[10],_[11],_[12],_[13],_[14],_[15],_[16]}
_[1]={_[3],_[4]}
return {tilew=16,image="dolphin.png",tileh=16,animations=_[1],name="dolphin",quads=_[2]}