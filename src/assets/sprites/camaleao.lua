local _={}
_[16]={160,32,32,32}
_[15]={128,32,32,32}
_[14]={96,32,32,32}
_[13]={64,32,32,32}
_[12]={32,32,32,32}
_[11]={0,32,32,32}
_[10]={160,0,32,32}
_[9]={128,0,32,32}
_[8]={96,0,32,32}
_[7]={64,0,32,32}
_[6]={32,0,32,32}
_[5]={0,0,32,32}
_[4]={stframe=6,enframe=9,name="walk"}
_[3]={stframe=0,enframe=5,name="idle"}
_[2]={_[5],_[6],_[7],_[8],_[9],_[10],_[11],_[12],_[13],_[14],_[15],_[16]}
_[1]={_[3],_[4]}
return {tilew=32,image="camaleao-anim.png",tileh=32,animations=_[1],name="camaleao",quads=_[2]}