local _={}
_[11]={stframe=0,enframe=4,name="walk"}
_[10]={stframe=0,enframe=0,name="idle"}
_[9]={384,0,64,64}
_[8]={320,0,64,64}
_[7]={256,0,64,64}
_[6]={192,0,64,64}
_[5]={128,0,64,64}
_[4]={64,0,64,64}
_[3]={0,0,64,64}
_[2]={_[10],_[11]}
_[1]={_[3],_[4],_[5],_[6],_[7],_[8],_[9]}
return {tilew=64,image="knight-walk.png",tileh=64,quads=_[1],name="knight",animations=_[2]}