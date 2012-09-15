package kha.android;

import android.content.Context;
import android.content.res.AssetManager;
import haxe.io.Bytes;
import java.io.Exceptions;
import java.lang.Number;
import java.lang.Object;
import java.NativeArray;
import kha.Blob;
import kha.FontStyle;

class Loader extends kha.Loader {
	var assets : AssetManager;
	
	public function new(context : Context) {
		super();
		this.assets = context.getAssets();
		Image.assets = assets;
	}
	
	override public function loadImage(filename : String) {
		images.set(filename, new Image(filename));
		--numberOfFiles;
		checkComplete();
	}

	override public function loadSound(filename : String) {
		try {
			sounds.set(filename, new Sound(assets.openFd(filename + ".wav")));
		}
		catch (ex : IOException) {
			ex.printStackTrace();
		}
		--numberOfFiles;
		checkComplete();
	}

	override public function loadMusic(filename : String) {
		try {
			musics.set(filename, new Music(assets.openFd(filename + ".ogg")));
		}
		catch (ex : IOException) {
			ex.printStackTrace();
		}
		--numberOfFiles;
		checkComplete();
	}
	
	override public function loadFont(name : String, style : FontStyle, size : Int) : kha.Font {
		return new Font(name, style, size);
	}
	
	override private function loadBlob(filename : String) : Void {
		var bytes : Array<Int> = new Array<Int>();
		try {
			var stream : java.io.InputStream = new java.io.BufferedInputStream(assets.open(filename));
			var c : Int = -1;
			while ((c = stream.read()) != -1) {
				bytes.push(c);
			}
			stream.close();
		}
		catch (ex : IOException) {
			
		}
		var array = new NativeArray(bytes.length);
		for (i in 0...bytes.length) array[i] = bytes[i];
		var hbytes = Bytes.ofData(array);
		blobs.set(filename, new kha.Blob(hbytes));
		--numberOfFiles;
		checkComplete();
	}

	override public function loadDataDefinition() : Void {
		var everything : String = "";
		try {
			everything = new java.util.Scanner(assets.open("data.xml")).useDelimiter("\\A").next();
		}
		catch (e : java.util.NoSuchElementException) {
			return;
		}
		xmls.set("data.xml", Xml.parse(everything));
		loadFiles();
	}
	
	@:functionBody('
		
	')
	override function loadXml(filename : String) : Void {
		var everything : String = "";
		try {
			everything = new java.util.Scanner(assets.open(filename)).useDelimiter("\\A").next();
		}
		catch (e : java.util.NoSuchElementException) {
			return;
		}
		xmls.set(filename, Xml.parse(everything));
		--numberOfFiles;
		checkComplete();
	}
	
	function checkComplete() : Void {
		if (numberOfFiles <= 0) {
			kha.Starter.loadFinished();
		}
	}
}