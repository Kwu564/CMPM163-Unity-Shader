using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System.IO;

public class MeltScript1 : MonoBehaviour {

	Renderer render;
	MeshCollider meshCollider;

	public AnimationCurve animaCurve;

	public float distance = 10.0f;

	public float duration = 0.0f;
	public float surfPoint = 0.0f;

	public float meltDist = 2.86f;

	// Use this for initialization
	void Start () {
		render = GetComponent<Renderer> ();
		meshCollider = GetComponent<MeshCollider> ();
		//GL.wireframe = true;
		setSurface ();
		//render.material.SetFloat("_MeltForm", 0.0f);
		//render.material.SetFloat("_MeltDist", 0.0f);
		StartCoroutine ("moveDown");

	}
	
	// Update is called once per frame
	void Update () {
		//Mesh mesh = GetComponent<MeshFilter> ().mesh;
		//meshCollider.sharedMesh = null;
		//meshCollider.sharedMesh = mesh;
	}

	void OnMouseDrag() {

		Vector3 heading = transform.position - Camera.main.transform.position;
		float dist = Vector3.Dot (heading, Camera.main.transform.forward);
		Vector3 mousePos = new Vector3 (Input.mousePosition.x, Input.mousePosition.y, dist);
		Vector3 objPos = Camera.main.ScreenToWorldPoint(mousePos);

		transform.position = objPos;


	}

	void OnMouseUp() {
		setSurface ();
	}

	void OnCollisionEnter(Collision collision) {
		
//		foreach( ContactPoint contact in collision.contacts) {
//			Debug.DrawRay (contact.point, contact.normal, Color.black);
//			//on contact, set the flat distance it can travel.  
//			Debug.Log("collision");
//			Debug.Log (contact.point);
//			float point = contact.point.y + 0.001f;
//			render.material.SetFloat ("_SurfPoint", point);
//		}
	}

	void setSurface() {
		RaycastHit hit;

		if (Physics.Raycast(transform.position, Vector3.down, out hit)) {
			Debug.Log (hit.distance);
			//Debug.Log (hit.transform.position);
			//Debug.Log(hit.distance- transform.position.y);
			surfPoint = -((hit.distance- transform.position.y));
			render.material.SetFloat("_SurfPoint", surfPoint);


		}


	}

	IEnumerator moveDown() {
		yield return new WaitForSeconds (5.0f);
		float timeAtPos = 0.0f;

		while (timeAtPos < duration) {
			timeAtPos += Time.deltaTime;

			float percent = Mathf.Clamp01 (timeAtPos / duration);
			float curveCent = animaCurve.Evaluate (percent);

			float val = Mathf.Lerp (0.0f, meltDist, curveCent);

			//float val2 = Mathf.Lerp (0.0f, meltDist, Mathf.Clamp01(curveCent*2.0f));
			render.material.SetFloat("_MeltVar", val);

			yield return null;
		}

		yield return null;
	}
}
