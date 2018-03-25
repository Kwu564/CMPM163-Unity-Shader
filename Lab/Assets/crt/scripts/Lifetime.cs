using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lifetime : MonoBehaviour {

    public int seconds;

	// Use this for initialization
	void Start () {
		StartCoroutine(Death());
	}
    
    IEnumerator Death() {
        yield return new WaitForSeconds(seconds);
        Destroy(gameObject);
    }
}
